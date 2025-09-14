import 'package:food_gram_app/core/cache/cache_manager.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/utils/geo_distance.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:logger/logger.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as maplibre;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'map_post_service.g.dart';

@riverpod
class MapPostService extends _$MapPostService {
  final logger = Logger();
  final _cacheManager = CacheManager();

  SupabaseClient get supabase => ref.read(supabaseProvider);

  List<String> get blockList =>
      ref.watch(blockListProvider).asData?.value ?? <String>[];

  @override
  Future<void> build() async {}

  /// ユーザーIDからユーザーデータを取得（Map向けに提供）
  Future<Map<String, dynamic>> getUserData(String userId) async {
    return _cacheManager.get<Map<String, dynamic>>(
      key: 'user_data_$userId',
      fetcher: () =>
          supabase.from('users').select().eq('user_id', userId).single(),
      duration: const Duration(minutes: 10),
    );
  }

  /// マップ表示用：座標付近の投稿一覧を取得
  Future<Result<List<Map<String, dynamic>>, Exception>> getRestaurantPosts({
    required double lat,
    required double lng,
  }) async {
    try {
      return Success(
        await _cacheManager.get<List<Map<String, dynamic>>>(
          key: 'restaurant_posts_${lat}_$lng',
          fetcher: () async {
            final posts = await supabase
                .from('posts')
                .select()
                .gte('lat', lat - 0.00001)
                .lte('lat', lat + 0.00001)
                .gte('lng', lng - 0.00001)
                .lte('lng', lng + 0.00001)
                .order('created_at');
            final filteredPosts = posts
                .where((post) => !blockList.contains(post['user_id']))
                .toList();
            return filteredPosts;
          },
          duration: const Duration(minutes: 5),
        ),
      );
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// マップ表示用：全投稿（ブロック除外）を取得
  Future<List<Map<String, dynamic>>> getMapPosts() async {
    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'map_posts',
      fetcher: () async {
        final blockListState = ref.watch(blockListProvider);
        List<String> currentBlockList;
        if (blockListState is AsyncData<List<String>>) {
          currentBlockList = blockListState.value;
        } else {
          currentBlockList = <String>[];
        }
        final posts = await supabase.from('posts').select().order('created_at');
        return posts
            .where((post) => !currentBlockList.contains(post['user_id']))
            .toList();
      },
      duration: const Duration(minutes: 5),
    );
  }

  /// 現在地から近い投稿を10件取得
  Future<List<Map<String, dynamic>>> getNearbyPosts() async {
    final currentLocation = await ref.read(locationProvider.future);
    if (currentLocation == const maplibre.LatLng(0, 0)) {
      return [];
    }
    final lat = currentLocation.latitude;
    final lng = currentLocation.longitude;

    return _cacheManager.get<List<Map<String, dynamic>>>(
      key: 'nearby_posts_${lat}_$lng',
      fetcher: () async {
        final posts = await supabase
            .from('posts')
            .select()
            .order('created_at', ascending: false);
        final filteredPosts = posts
            .where((post) => !blockList.contains(post['user_id']))
            .toList();
        final uniqueLocationPosts = <String, Map<String, dynamic>>{};
        for (final post in filteredPosts) {
          final locationKey = '${post['lat']}_${post['lng']}';
          if (!uniqueLocationPosts.containsKey(locationKey)) {
            uniqueLocationPosts[locationKey] = post;
          }
        }

        final postsWithDistance = uniqueLocationPosts.values.map((post) {
          final distance = geoKilometers(
            lat1: lat,
            lon1: lng,
            lat2: double.parse(post['lat'].toString()),
            lon2: double.parse(post['lng'].toString()),
          );
          return {...post, 'distance': distance};
        }).toList()
          ..sort(
            (a, b) =>
                (a['distance'] as double).compareTo(b['distance'] as double),
          );

        return postsWithDistance.take(10).map((post) {
          final result = Map<String, dynamic>.from(post)..remove('distance');
          return result;
        }).toList();
      },
      duration: const Duration(minutes: 5),
    );
  }
}
