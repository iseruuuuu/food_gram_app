import 'package:enum_to_string/enum_to_string.dart';
import 'package:food_gram_app/core/model/post_draft.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/restaurant_search_history.dart';
import 'package:food_gram_app/core/model/want_to_go_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKey {
  blockList,
  friendList,
  isFinishedTutorial,
  isAccept,
  heartList,
  storeList,
  saveAlbumIds,
  lastReviewRequestDate,
  firstLaunchDate,
  postDraft,
  analyticsFirstRecordOpen,
  analyticsFirstInsightOpen,
  analyticsFirstJapanMapOpen,
  analyticsFirstWorldMapOpen,
  analyticsFirstPostWithComment,
  analyticsFirstPostWithRestaurant,
  analyticsFirstCountryComplete,
  analyticsFirstPrefectureComplete,
  analyticsHighestPostMilestone,
  memoryAlbums,
  lastWeeklySummaryWeekStart,
  lastMonthlySummaryMonthStart,
  wantToGoList,
  hasSeenFirstPostGuide,
  hasSeenFirstPostSuccessGuide,
  restaurantSearchHistory,
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

  final Map<String, Future<void>> _stringListWriteChains = {};

  String _getKey(PreferenceKey key) => EnumToString.convertToString(key);

  String _getUserKey(PreferenceKey key, String userId) =>
      '${_getKey(key)}_$userId';

  Future<T> _withSerializedStringListWrite<T>(
    String storageKey,
    Future<T> Function() action,
  ) {
    final previous = _stringListWriteChains[storageKey] ?? Future<void>.value();
    final next = previous.catchError((_) {}).then((_) => action());
    _stringListWriteChains[storageKey] = next.then<void>(
      (_) {},
      onError: (_) {},
    );
    return next;
  }

  Future<void> setStringList(PreferenceKey key, List<String> value) async {
    final pref = await _prefs;
    await pref.setStringList(_getKey(key), value);
  }

  Future<List<String>> getStringList(PreferenceKey key) async {
    final pref = await _prefs;
    return pref.getStringList(_getKey(key)) ?? [];
  }

  Future<void> remove(PreferenceKey key) async {
    final pref = await _prefs;
    await pref.remove(_getKey(key));
  }

  Future<List<String>> getStringListForUser(
    PreferenceKey key,
    String userId,
  ) async {
    final pref = await _prefs;
    return pref.getStringList(_getUserKey(key, userId)) ?? [];
  }

  /// 同一ユーザーキーへの read-modify-write を直列化する。
  Future<List<String>> updateStringListForUser(
    PreferenceKey key,
    String userId,
    List<String> Function(List<String> current) update,
  ) {
    final storageKey = _getUserKey(key, userId);
    return _withSerializedStringListWrite(storageKey, () async {
      final pref = await _prefs;
      final current = pref.getStringList(storageKey) ?? [];
      final next = update(current);
      await pref.setStringList(storageKey, next);
      return next;
    });
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

  Future<PostDraft?> getPostDraft() async {
    final raw = await getString(PreferenceKey.postDraft);
    return PostDraft.fromJsonString(raw);
  }

  Future<void> savePostDraft(PostDraft draft) async {
    await setString(PreferenceKey.postDraft, draft.toJsonString());
  }

  Future<void> clearPostDraft() async {
    await setString(PreferenceKey.postDraft, '');
  }

  Future<List<WantToGoItem>> getWantToGoList() async {
    try {
      final pref = await _prefs;
      final key = _getKey(PreferenceKey.wantToGoList);
      final value = pref.get(key);

      // 新形式（JSON 文字列）
      if (value is String && value.isNotEmpty) {
        return WantToGoStore.fromJsonString(value).items;
      }

      // 旧形式（店名の StringList）からの移行
      if (value is List) {
        final migrated = value
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .map(WantToGoItem.fromLegacyName)
            .toList();
        await saveWantToGoList(migrated);
        return migrated;
      }

      return [];
    } on Object {
      // 型不一致などで読めない場合は空として扱う
      return [];
    }
  }

  Future<void> saveWantToGoList(List<WantToGoItem> items) => setString(
        PreferenceKey.wantToGoList,
        WantToGoStore(items).toJsonString(),
      );

  Future<List<Restaurant>> getRestaurantSearchHistory() async {
    final raw = await getString(PreferenceKey.restaurantSearchHistory);
    return RestaurantSearchHistoryStore.fromJsonString(raw).items;
  }

  Future<void> saveRestaurantSearchHistory(List<Restaurant> items) =>
      setString(
        PreferenceKey.restaurantSearchHistory,
        RestaurantSearchHistoryStore(items).toJsonString(),
      );
}
