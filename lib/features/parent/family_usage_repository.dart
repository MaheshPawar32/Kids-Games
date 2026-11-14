import 'package:shared_preferences/shared_preferences.dart';

abstract interface class FamilyUsageRepository {
  Future<int> loadTodaySeconds(DateTime now);
  Future<void> saveTodaySeconds(int seconds, DateTime now);
}

class PreferencesFamilyUsageRepository implements FamilyUsageRepository {
  PreferencesFamilyUsageRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _dateKey = 'family_usage_date_v1';
  static const _secondsKey = 'family_usage_seconds_v1';

  final SharedPreferencesAsync _preferences;

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  @override
  Future<int> loadTodaySeconds(DateTime now) async {
    final values = await Future.wait<Object?>([
      _preferences.getString(_dateKey),
      _preferences.getInt(_secondsKey),
    ]);
    if (values[0] != _date(now)) return 0;
    return ((values[1] as int?) ?? 0).clamp(0, 24 * 60 * 60).toInt();
  }

  @override
  Future<void> saveTodaySeconds(int seconds, DateTime now) async {
    await Future.wait<void>([
      _preferences.setString(_dateKey, _date(now)),
      _preferences.setInt(_secondsKey, seconds.clamp(0, 24 * 60 * 60).toInt()),
    ]);
  }
}

class MemoryFamilyUsageRepository implements FamilyUsageRepository {
  String? _date;
  int _seconds = 0;

  String _dateFor(DateTime value) =>
      '${value.year}-${value.month}-${value.day}';

  @override
  Future<int> loadTodaySeconds(DateTime now) async {
    if (_date != _dateFor(now)) {
      _date = _dateFor(now);
      _seconds = 0;
    }
    return _seconds;
  }

  @override
  Future<void> saveTodaySeconds(int seconds, DateTime now) async {
    _date = _dateFor(now);
    _seconds = seconds.clamp(0, 24 * 60 * 60).toInt();
  }
}
