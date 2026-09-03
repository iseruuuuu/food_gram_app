import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/restaurant_search_history.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'restaurant_search_history_notifier.g.dart';

/// 投稿のレストラン検索で確定した店舗履歴。
@riverpod
class RestaurantSearchHistoryNotifier
    extends _$RestaurantSearchHistoryNotifier {
  final _preference = Preference();

  @override
  Future<List<Restaurant>> build() async =>
      _preference.getRestaurantSearchHistory();

  /// build() 完了後の一覧を使う（読み込み中のディスク再読込はしない）
  Future<List<Restaurant>> _currentList() async =>
      List<Restaurant>.from(await future);

  Future<void> add(Restaurant restaurant) async {
    final next = RestaurantSearchHistoryStore(await _currentList())
        .add(restaurant)
        .items;
    await _preference.saveRestaurantSearchHistory(next);
    state = AsyncData(next);
  }

  Future<void> remove(Restaurant restaurant) async {
    final next = RestaurantSearchHistoryStore(await _currentList())
        .remove(restaurant)
        .items;
    await _preference.saveRestaurantSearchHistory(next);
    state = AsyncData(next);
  }
}
