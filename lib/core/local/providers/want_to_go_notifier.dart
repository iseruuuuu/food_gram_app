import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/want_to_go_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'want_to_go_notifier.g.dart';

@riverpod
class WantToGoNotifier extends _$WantToGoNotifier {
  final _preference = Preference();

  @override
  Future<List<WantToGoItem>> build() async => _preference.getWantToGoList();

  /// build() 完了後の一覧を使う（読み込み中のディスク再読込はしない）
  Future<List<WantToGoItem>> _currentList() async =>
      List<WantToGoItem>.from(await future);

  bool contains(Restaurant restaurant) {
    final key = WantToGoItem.identityKeyForRestaurant(restaurant);
    return state.valueOrNull?.any((e) => e.id == key) ?? false;
  }

  Future<bool> toggle(Restaurant restaurant) async {
    final name = restaurant.name.trim();
    if (name.isEmpty) {
      return false;
    }
    final key = WantToGoItem.identityKeyForRestaurant(restaurant);
    final list = await _currentList();
    final index = list.indexWhere((e) => e.id == key);
    final added = index < 0;
    if (added) {
      list.insert(0, WantToGoItem.fromRestaurant(restaurant));
    } else {
      list.removeAt(index);
    }
    await _preference.saveWantToGoList(list);
    state = AsyncData(list);
    return added;
  }

  Future<void> removeById(String id) async {
    final list = await _currentList()..removeWhere((e) => e.id == id);
    await _preference.saveWantToGoList(list);
    state = AsyncData(list);
  }
}
