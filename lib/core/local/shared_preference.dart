import 'package:enum_to_string/enum_to_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKey {
  blockList,
  isFinishedTutorial,
  isAccept,
  heartList,
}

class Preference {
  factory Preference() {
    return _instance ??= Preference._();
  }

  Preference._() {
    _prefs = SharedPreferences.getInstance();
  }
  static Preference? _instance;
  late final Future<SharedPreferences> _prefs;

  String _getKey(PreferenceKey key) => EnumToString.convertToString(key);

  Future<void> setStringList(PreferenceKey key, List<String> value) async {
    final pref = await _prefs;
    await pref.setStringList(_getKey(key), value);
  }

  Future<List<String>> getStringList(PreferenceKey key) async {
    final pref = await _prefs;
    return pref.getStringList(_getKey(key)) ?? [];
  }

  Future<void> setBool(PreferenceKey key) async {
    final pref = await _prefs;
    await pref.setBool(_getKey(key), true);
  }

  Future<bool> getBool(PreferenceKey key) async {
    final pref = await _prefs;
    return pref.getBool(_getKey(key)) ?? false;
  }
}
