import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Parent-only preferences stored locally on this device.
class ParentControls {
  const ParentControls({
    this.dailyLimitMinutes = 60,
    this.bedtimeEnabled = false,
    this.bedtimeStartMinute = 20 * 60,
    this.bedtimeEndMinute = 7 * 60,
    this.soundEnabled = true,
    this.reducedMotion = false,
  });

  final int dailyLimitMinutes;
  final bool bedtimeEnabled;
  final int bedtimeStartMinute;
  final int bedtimeEndMinute;
  final bool soundEnabled;
  final bool reducedMotion;

  ParentControls copyWith({
    int? dailyLimitMinutes,
    bool? bedtimeEnabled,
    int? bedtimeStartMinute,
    int? bedtimeEndMinute,
    bool? soundEnabled,
    bool? reducedMotion,
  }) {
    return ParentControls(
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      bedtimeEnabled: bedtimeEnabled ?? this.bedtimeEnabled,
      bedtimeStartMinute: bedtimeStartMinute ?? this.bedtimeStartMinute,
      bedtimeEndMinute: bedtimeEndMinute ?? this.bedtimeEndMinute,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }
}

abstract interface class ParentAccessRepository {
  Future<bool> hasPin();
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<ParentControls> loadControls();
  Future<void> saveControls(ParentControls controls);
}

/// Encrypted PIN storage plus PBKDF2-HMAC-SHA256 password verification.
class SecureParentAccessRepository implements ParentAccessRepository {
  SecureParentAccessRepository({
    FlutterSecureStorage? secureStorage,
    SharedPreferencesAsync? preferences,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _preferences = preferences ?? SharedPreferencesAsync();

  static const _saltKey = 'parent_pin_salt_v1';
  static const _hashKey = 'parent_pin_hash_v1';
  static const _dailyLimitKey = 'parent_daily_limit_minutes';
  static const _bedtimeEnabledKey = 'parent_bedtime_enabled';
  static const _bedtimeStartKey = 'parent_bedtime_start_minute';
  static const _bedtimeEndKey = 'parent_bedtime_end_minute';
  static const _soundEnabledKey = 'parent_sound_enabled';
  static const _reducedMotionKey = 'parent_reduced_motion';

  static final Pbkdf2 _kdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );

  final FlutterSecureStorage _secureStorage;
  final SharedPreferencesAsync _preferences;

  @override
  Future<bool> hasPin() async =>
      await _secureStorage.read(key: _hashKey) != null;

  @override
  Future<void> setPin(String pin) async {
    if (!RegExp(r'^[0-9]{6}$').hasMatch(pin)) {
      throw ArgumentError.value(pin, 'pin', 'PIN must contain six digits.');
    }
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final derived = await _kdf.deriveKeyFromPassword(
      password: pin,
      nonce: salt,
    );
    final hash = await derived.extractBytes();
    await _secureStorage.write(key: _saltKey, value: base64UrlEncode(salt));
    await _secureStorage.write(key: _hashKey, value: base64UrlEncode(hash));
  }

  @override
  Future<bool> verifyPin(String pin) async {
    if (!RegExp(r'^[0-9]{6}$').hasMatch(pin)) return false;
    final saltValue = await _secureStorage.read(key: _saltKey);
    final expectedValue = await _secureStorage.read(key: _hashKey);
    if (saltValue == null || expectedValue == null) return false;

    final salt = base64Url.decode(saltValue);
    final expected = base64Url.decode(expectedValue);
    final derived = await _kdf.deriveKeyFromPassword(
      password: pin,
      nonce: salt,
    );
    final actual = await derived.extractBytes();
    if (actual.length != expected.length) return false;

    var difference = 0;
    for (var index = 0; index < actual.length; index++) {
      difference |= actual[index] ^ expected[index];
    }
    return difference == 0;
  }

  @override
  Future<ParentControls> loadControls() async {
    final values = await Future.wait<Object?>([
      _preferences.getInt(_dailyLimitKey),
      _preferences.getBool(_bedtimeEnabledKey),
      _preferences.getInt(_bedtimeStartKey),
      _preferences.getInt(_bedtimeEndKey),
      _preferences.getBool(_soundEnabledKey),
      _preferences.getBool(_reducedMotionKey),
    ]);
    return ParentControls(
      dailyLimitMinutes: (values[0] as int?) ?? 60,
      bedtimeEnabled: (values[1] as bool?) ?? false,
      bedtimeStartMinute: (values[2] as int?) ?? 20 * 60,
      bedtimeEndMinute: (values[3] as int?) ?? 7 * 60,
      soundEnabled: (values[4] as bool?) ?? true,
      reducedMotion: (values[5] as bool?) ?? false,
    );
  }

  @override
  Future<void> saveControls(ParentControls controls) async {
    await Future.wait<void>([
      _preferences.setInt(_dailyLimitKey, controls.dailyLimitMinutes),
      _preferences.setBool(_bedtimeEnabledKey, controls.bedtimeEnabled),
      _preferences.setInt(_bedtimeStartKey, controls.bedtimeStartMinute),
      _preferences.setInt(_bedtimeEndKey, controls.bedtimeEndMinute),
      _preferences.setBool(_soundEnabledKey, controls.soundEnabled),
      _preferences.setBool(_reducedMotionKey, controls.reducedMotion),
    ]);
  }
}

/// In-memory implementation used by widget tests and previews only.
class MemoryParentAccessRepository implements ParentAccessRepository {
  String? _pin;
  ParentControls _controls = const ParentControls();

  @override
  Future<bool> hasPin() async => _pin != null;

  @override
  Future<void> setPin(String pin) async {
    if (!RegExp(r'^[0-9]{6}$').hasMatch(pin)) {
      throw ArgumentError.value(pin, 'pin', 'PIN must contain six digits.');
    }
    _pin = pin;
  }

  @override
  Future<bool> verifyPin(String pin) async => _pin == pin;

  @override
  Future<ParentControls> loadControls() async => _controls;

  @override
  Future<void> saveControls(ParentControls controls) async {
    _controls = controls;
  }
}

bool isWithinBedtimeSchedule(DateTime now, ParentControls controls) {
  if (!controls.bedtimeEnabled) return false;
  final currentMinute = now.hour * 60 + now.minute;
  final start = controls.bedtimeStartMinute.clamp(0, 1439);
  final end = controls.bedtimeEndMinute.clamp(0, 1439);
  if (start == end) return false;
  if (start < end) {
    return currentMinute >= start && currentMinute < end;
  }
  return currentMinute >= start || currentMinute < end;
}
