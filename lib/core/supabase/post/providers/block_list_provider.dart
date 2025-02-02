import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'block_list_provider.g.dart';

@riverpod
Future<List<String>> blockList(Ref ref) async {
  final preference = Preference();
  return preference.getStringList(PreferenceKey.blockList);
}
