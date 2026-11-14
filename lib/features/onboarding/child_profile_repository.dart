import 'package:shared_preferences/shared_preferences.dart';

import 'child_profile.dart';

abstract interface class ChildProfileRepository {
  Future<ChildProfile?> loadProfile();
  Future<void> saveProfile(ChildProfile profile);
  Future<void> clearProfile();
}

class PreferencesChildProfileRepository implements ChildProfileRepository {
  PreferencesChildProfileRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _nameKey = 'child_profile_name';
  static const _gradeKey = 'child_profile_grade';

  final SharedPreferencesAsync _preferences;

  @override
  Future<ChildProfile?> loadProfile() async {
    final values = await Future.wait<String?>([
      _preferences.getString(_nameKey),
      _preferences.getString(_gradeKey),
    ]);
    final name = values[0];
    final grade = values[1];

    if (name == null || name.trim().isEmpty || grade == null) {
      return null;
    }

    return ChildProfile(name: name, grade: grade);
  }

  @override
  Future<void> saveProfile(ChildProfile profile) async {
    await _preferences.setString(_nameKey, profile.name);
    await _preferences.setString(_gradeKey, profile.grade);
  }

  @override
  Future<void> clearProfile() async {
    await _preferences.remove(_nameKey);
    await _preferences.remove(_gradeKey);
  }
}
