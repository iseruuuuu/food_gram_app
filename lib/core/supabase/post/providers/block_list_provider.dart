import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'block_list_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<String>> blockList(Ref ref) {
  CacheManager().invalidateBlockRelatedCaches();
  final preference = Preference();
  return preference.getStringList(PreferenceKey.blockList);
}
