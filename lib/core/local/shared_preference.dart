import 'package:enum_to_string/enum_to_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKey {
  blockList,
  isFinishedTutorial,
  isAccept,
  heartList,
  heartCount,
  heartDate,
  storeList,
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

  Future<void> setInt(PreferenceKey key, int value) async {
    final pref = await _prefs;
    await pref.setInt(_getKey(key), value);
  }

  Future<int> getInt(PreferenceKey key) async {
    final pref = await _prefs;
    return pref.getInt(_getKey(key)) ?? 0;
  }

  Future<void> setString(PreferenceKey key, String value) async {
    final pref = await _prefs;
    await pref.setString(_getKey(key), value);
  }

  Future<String> getString(PreferenceKey key) async {
    final pref = await _prefs;
    return pref.getString(_getKey(key)) ?? '';
  }

  /// 同じ日付で10回以上いいねした場合はfalseを返す
  Future<bool> canLike() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final storedDate = await getString(PreferenceKey.heartDate);
    final currentCount = await getInt(PreferenceKey.heartCount);

    // 日付が変わった場合はカウントをリセット
    if (storedDate != today) {
      await setString(PreferenceKey.heartDate, today);
      await setInt(PreferenceKey.heartCount, 0);
      return true;
    }

    // 10回以上いいねした場合はfalse
    return currentCount < 10;
  }

  /// いいねカウントを増加
  Future<void> incrementHeartCount() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final storedDate = await getString(PreferenceKey.heartDate);
    final currentCount = await getInt(PreferenceKey.heartCount);

    // 初回のいいねまたは日付が変わった場合は日付を設定
    if (storedDate.isEmpty || storedDate != today) {
      await setString(PreferenceKey.heartDate, today);
      await setInt(PreferenceKey.heartCount, 1);
    } else {
      // 同じ日付の場合はカウントを増加
      await setInt(PreferenceKey.heartCount, currentCount + 1);
    }
  }
}
