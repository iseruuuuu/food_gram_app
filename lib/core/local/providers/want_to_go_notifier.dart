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

  bool containsName(String name) {
    final trimmed = name.trim();
    return state.valueOrNull?.any((e) => e.name == trimmed) ?? false;
  }

  Future<bool> toggle(Restaurant restaurant) async {
    final name = restaurant.name.trim();
    if (name.isEmpty) {
      return false;
    }
    final list = List<WantToGoItem>.from(
      state.valueOrNull ?? await _preference.getWantToGoList(),
    );
    final index = list.indexWhere((e) => e.name == name);
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

  Future<void> remove(String name) async {
    final list = List<WantToGoItem>.from(
      state.valueOrNull ?? await _preference.getWantToGoList(),
    )..removeWhere((e) => e.name == name);
    await _preference.saveWantToGoList(list);
    state = AsyncData(list);
  }
}
