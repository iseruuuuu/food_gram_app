import 'package:enum_to_string/enum_to_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKey {
  blockList,
  isFinishedTutorial,
}

class Preference {
  final preference = SharedPreferences.getInstance();

  Future<void> setStringList(PreferenceKey key, List<String> value) async {
    final pref = await preference;
    await pref.setStringList(EnumToString.convertToString(key), value);
  }

  Future<List<String>> getStringList(PreferenceKey key) async {
    final pref = await preference;
    final value = pref.getStringList(EnumToString.convertToString(key)) ?? [];
    return value;
  }

  Future<void> setBool(PreferenceKey key) async {
    final pref = await preference;
    await pref.setBool(EnumToString.convertToString(key), true);
  }

  Future<bool> getBool(PreferenceKey key) async {
    final pref = await preference;
    final value = pref.getBool(EnumToString.convertToString(key)) ?? false;
    return value;
  }
}
