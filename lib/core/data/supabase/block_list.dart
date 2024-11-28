import 'package:food_gram_app/core/config/shared_preference/shared_preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'block_list.g.dart';

@riverpod
Future<List<String>> blockList(BlockListRef ref) async {
  final preference = Preference();
  return preference.getStringList(PreferenceKey.blockList);
}
