import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/post_deail_list_mode.dart';
import 'package:food_gram_app/core/model/post_detail_feed.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/fetch_post_repository.dart';
import 'package:food_gram_app/core/supabase/post/services/detail_post_service.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'detail_post_repository.g.dart';

@riverpod
class DetailPostRepository extends _$DetailPostRepository {
  @override
  Future<void> build() async {}
  final logger = Logger();

  /// 特定の投稿を取得
  Future<Result<Posts, Exception>> getPost(int postId) async {
    try {
      final service = ref.read(detailPostServiceProvider.notifier);
      final result = await service.getPost(postId);
      return result.when(
        success: (data) =>
            Success(Posts.fromJson(data['post'] as Map<String, dynamic>)),
        failure: Failure.new,
      );
    } on PostgrestException catch (e) {
      return Failure(e);
    }
  }

  Future<Result<List<Posts>, Exception>> getPostsFromUser(String userId) async {
    try {
      final data = await ref
          .read(detailPostServiceProvider.notifier)
          .getPostsFromUserPaged(userId, limit: 60);
      return Success(data.map(Posts.fromJson).toList());
    } on PostgrestException catch (e) {
      logger.e('Database error: ${e.message}');
      return Failure(e);
    }
  }

  /// ユーザーデータを取得
  Future<Map<String, dynamic>> getUserData(String userId) async {
    final service = ref.read(detailPostServiceProvider.notifier);
    return service.getUserData(userId);
  }

  /// ユーザーデータを取得
  Future<Result<Model, Exception>> getPostData(
    List<Posts> posts,
    int index,
  ) async {
    try {
      final service = ref.read(detailPostServiceProvider.notifier);
      if (index < 0 || index >= posts.length) {
        return Failure(Exception('index out of range: $index'));
      }
      final selectedPost = posts[index];
      final userId = selectedPost.userId;
      if (userId.isEmpty) {
        return Failure(Exception('empty userId (index=$index)'));
      }
      final userData = await service.getUserData(userId);
      final user = Users.fromJson(userData);
      return Success(Model(user, selectedPost));
    } on PostgrestException catch (e) {
      return Failure(e);
    }
  }

  /// 指定した投稿IDより古い投稿のリストを取得する。
  /// [categoryName] を指定した場合はそのカテゴリに属する投稿のみ返す（多めに取得してフィルタする）。
  Future<Result<List<Model>, Exception>> getSequentialPosts({
    required int currentPostId,
    int limit = 10,
    String? categoryName,
  }) async {
    try {
      final service = ref.read(detailPostServiceProvider.notifier);
      final fetchLimit =
          (categoryName != null && categoryName.isNotEmpty) ? 50 : limit;
      final result = await service.getSequentialPosts(
        currentPostId: currentPostId,
        limit: fetchLimit,
      );
      return await result.when(
        success: (data) async {
          final blockList =
              ref.read(blockListProvider).asData?.value ?? const <String>[];
          final List<String>? foodEmojis;
          if (categoryName != null && categoryName.isNotEmpty) {
            final emojis = foodCategory[categoryName];
            if (emojis == null) {
              logger.w(
                'Unknown category passed to getSequentialPosts: '
                '"$categoryName". No posts will match.',
              );
            }
            foodEmojis = emojis ?? <String>[];
          } else {
            foodEmojis = null;
          }
          final sorted = [...data]..sort(
              (a, b) => ((b['id'] as num).toInt())
                  .compareTo((a['id'] as num).toInt()),
            );
          final seen = <int>{};
          final picked = <Map<String, dynamic>>[];
          for (final m in sorted) {
            final id = (m['id'] as num).toInt();
            if (id >= currentPostId) {
              continue;
            }
            if (foodEmojis != null) {
              final tag = m['food_tag'] as String? ?? '';
              final postTags = parseFoodTagIds(tag);
              if (!postTags.any(foodEmojis.contains)) {
                continue;
              }
            }
            if (seen.add(id)) {
              picked.add(m);
              if (picked.length >= limit) {
                break;
              }
            }
          }
          final filtered = picked
              .where((m) => !blockList.contains(m['user_id'] as String? ?? ''))
              .toList(growable: false);
          final futures = filtered.map((postData) async {
            final userId = postData['user_id'] as String?;
            if (userId == null) {
              return null;
            }
            final userData = await service.getUserData(userId);
            return Model(Users.fromJson(userData), Posts.fromJson(postData));
          }).toList();
          final models =
              (await Future.wait<Model?>(futures)).whereType<Model>().toList();
          return Success<List<Model>, Exception>(models);
        },
        failure: (e) async => Failure<List<Model>, Exception>(e),
      );
    } on PostgrestException catch (e) {
      return Failure<List<Model>, Exception>(e);
    }
  }

  /// 指定した投稿IDと同じレストランの投稿のリストを取得する
  Future<Result<List<Model>, Exception>> getRelatedPosts({
    required int currentPostId,
    required double lat,
    required double lng,
  }) async {
    try {
      final service = ref.read(detailPostServiceProvider.notifier);
      final result = await service.getRelatedPosts(
        currentPostId: currentPostId,
        lat: lat,
        lng: lng,
      );
      return await result.when(
        success: (data) async {
          final blockList =
              ref.read(blockListProvider).asData?.value ?? const <String>[];
          final filtered = data
              .where((m) => !blockList.contains(m['user_id'] as String? ?? ''))
              .toList(growable: false);
          final futures = filtered.map((postData) async {
            final userId = postData['user_id'] as String?;
            if (userId == null) {
              return null;
            }
            final userData = await service.getUserData(userId);
            return Model(Users.fromJson(userData), Posts.fromJson(postData));
          }).toList();
          final models =
              (await Future.wait<Model?>(futures)).whereType<Model>().toList();
          return Success<List<Model>, Exception>(models);
        },
        failure: (e) async => Failure<List<Model>, Exception>(e),
      );
    } on PostgrestException catch (e) {
      return Failure<List<Model>, Exception>(e);
    }
  }

  /// 投稿詳細画面のリストを mode ごとに返す（初期投稿の前後を少量だけ含む）
  Future<PostDetailListResult> getPostDetailList({
    required Posts initialPost,
    required PostDetailListMode mode,
    String? profileUserId,
    String? restaurant,
    String? categoryName,
  }) async {
    switch (mode) {
      case PostDetailListMode.timeline:
        return _timelineFeed(
          initialPost: initialPost,
          categoryName: categoryName,
        );
      case PostDetailListMode.myprofile:
        {
          final currentUser = ref.watch(currentUserProvider);
          if (currentUser == null) {
            return _single(initialPost);
          }
          return _userFeed(userId: currentUser, initialPost: initialPost);
        }
      case PostDetailListMode.profile:
        {
          final userId = profileUserId;
          if (userId == null || userId.isEmpty) {
            return _single(initialPost);
          }
          return _userFeed(userId: userId, initialPost: initialPost);
        }
      case PostDetailListMode.nearby:
        return _nearbyFeed(initialPost: initialPost);
      case PostDetailListMode.search:
        {
          final name = restaurant ?? initialPost.restaurant;
          final posts = await _restaurantPosts(name);
          return takePostsAround(
            sortedNewestFirst: posts,
            initial: initialPost,
          );
        }
      case PostDetailListMode.stored:
        {
          final ordered = await _storedPosts();
          if (ordered.isEmpty) {
            return const PostDetailListResult(
              posts: [],
              hasMoreNewer: false,
              hasMoreOlder: false,
            );
          }
          return takePostsAround(
            sortedNewestFirst: ordered,
            initial: initialPost,
          );
        }
    }
  }

  /// 投稿詳細フィードの追加ページを取得する
  Future<List<Posts>> getPostDetailPage({
    required Posts cursorPost,
    required PostDetailListMode mode,
    required PostDetailPageDirection direction,
    String? profileUserId,
    String? restaurant,
    String? categoryName,
  }) async {
    final isNewer = direction == PostDetailPageDirection.newer;
    final limit = isNewer ? postDetailNewerPageSize : postDetailOlderPageSize;
    switch (mode) {
      case PostDetailListMode.timeline:
        {
          final items = await _sequentialPostItems(
            currentPostId: cursorPost.id,
            newer: isNewer,
            limit: limit,
            categoryName: categoryName,
          );
          return isNewer ? items.reversed.toList() : items;
        }
      case PostDetailListMode.myprofile:
        {
          final currentUser = ref.watch(currentUserProvider);
          if (currentUser == null) {
            return const [];
          }
          return _userPostItems(
            userId: currentUser,
            cursorId: cursorPost.id,
            newer: isNewer,
            limit: limit,
          );
        }
      case PostDetailListMode.profile:
        {
          final userId = profileUserId;
          if (userId == null || userId.isEmpty) {
            return const [];
          }
          return _userPostItems(
            userId: userId,
            cursorId: cursorPost.id,
            newer: isNewer,
            limit: limit,
          );
        }
      case PostDetailListMode.nearby:
        return _relatedPostItems(
          currentPostId: cursorPost.id,
          lat: cursorPost.lat,
          lng: cursorPost.lng,
          newer: isNewer,
          limit: limit,
          createdAt: cursorPost.createdAt,
        );
      case PostDetailListMode.search:
        {
          final name = restaurant ?? cursorPost.restaurant;
          final posts = await _restaurantPosts(name);
          return isNewer
              ? takeNewerPage(
                  sortedNewestFirst: posts,
                  cursor: cursorPost,
                  limit: limit,
                )
              : takeOlderPage(
                  sortedNewestFirst: posts,
                  cursor: cursorPost,
                  limit: limit,
                );
        }
      case PostDetailListMode.stored:
        {
          final ordered = await _storedPosts();
          return isNewer
              ? takeNewerPage(
                  sortedNewestFirst: ordered,
                  cursor: cursorPost,
                  limit: limit,
                )
              : takeOlderPage(
                  sortedNewestFirst: ordered,
                  cursor: cursorPost,
                  limit: limit,
                );
        }
    }
  }

  PostDetailListResult _single(Posts initialPost) {
    return PostDetailListResult(
      posts: [initialPost],
      hasMoreNewer: false,
      hasMoreOlder: false,
    );
  }

  Future<PostDetailListResult> _timelineFeed({
    required Posts initialPost,
    String? categoryName,
  }) async {
    final newerFuture = _sequentialPostItems(
      currentPostId: initialPost.id,
      newer: true,
      limit: postDetailNewerPageSize,
      categoryName: categoryName,
    );
    final olderFuture = _sequentialPostItems(
      currentPostId: initialPost.id,
      newer: false,
      limit: postDetailOlderPageSize,
      categoryName: categoryName,
    );
    final newerClosestFirst = await newerFuture;
    final olderClosestFirst = await olderFuture;
    return PostDetailListResult(
      posts: [
        ...newerClosestFirst.reversed,
        initialPost,
        ...olderClosestFirst,
      ],
      hasMoreNewer: newerClosestFirst.length >= postDetailNewerPageSize,
      hasMoreOlder: olderClosestFirst.length >= postDetailOlderPageSize,
    );
  }

  Future<PostDetailListResult> _userFeed({
    required String userId,
    required Posts initialPost,
  }) async {
    final newerFuture = _userPostItems(
      userId: userId,
      cursorId: initialPost.id,
      newer: true,
      limit: postDetailNewerPageSize,
    );
    final olderFuture = _userPostItems(
      userId: userId,
      cursorId: initialPost.id,
      newer: false,
      limit: postDetailOlderPageSize,
    );
    final newerClosestFirst = await newerFuture;
    final olderClosestFirst = await olderFuture;
    return PostDetailListResult(
      posts: [
        ...newerClosestFirst.reversed,
        initialPost,
        ...olderClosestFirst,
      ],
      hasMoreNewer: newerClosestFirst.length >= postDetailNewerPageSize,
      hasMoreOlder: olderClosestFirst.length >= postDetailOlderPageSize,
    );
  }

  Future<PostDetailListResult> _nearbyFeed({
    required Posts initialPost,
  }) async {
    final newerFuture = _relatedPostItems(
      currentPostId: initialPost.id,
      lat: initialPost.lat,
      lng: initialPost.lng,
      newer: true,
      limit: postDetailNewerPageSize,
      createdAt: initialPost.createdAt,
    );
    final olderFuture = _relatedPostItems(
      currentPostId: initialPost.id,
      lat: initialPost.lat,
      lng: initialPost.lng,
      newer: false,
      limit: postDetailOlderPageSize,
      createdAt: initialPost.createdAt,
    );
    final newerClosestFirst = await newerFuture;
    final olderClosestFirst = await olderFuture;
    return PostDetailListResult(
      posts: [
        ...newerClosestFirst.reversed,
        initialPost,
        ...olderClosestFirst,
      ],
      hasMoreNewer: newerClosestFirst.length >= postDetailNewerPageSize,
      hasMoreOlder: olderClosestFirst.length >= postDetailOlderPageSize,
    );
  }

  Future<List<Posts>> _sequentialPostItems({
    required int currentPostId,
    required bool newer,
    required int limit,
    String? categoryName,
  }) async {
    final service = ref.read(detailPostServiceProvider.notifier);
    final fetchLimit =
        (categoryName != null && categoryName.isNotEmpty) ? limit * 5 : limit;
    final result = newer
        ? await service.getNewerSequentialPosts(
            currentPostId: currentPostId,
            limit: fetchLimit,
          )
        : await service.getSequentialPosts(
            currentPostId: currentPostId,
            limit: fetchLimit,
          );
    return result.when(
      success: (data) => _pickSequentialPosts(
        data,
        currentPostId: currentPostId,
        newer: newer,
        limit: limit,
        categoryName: categoryName,
      ),
      failure: (_) => const [],
    );
  }

  List<Posts> _pickSequentialPosts(
    List<Map<String, dynamic>> data, {
    required int currentPostId,
    required bool newer,
    required int limit,
    String? categoryName,
  }) {
    final blockList =
        ref.read(blockListProvider).asData?.value ?? const <String>[];
    final List<String>? foodEmojis;
    if (categoryName != null && categoryName.isNotEmpty) {
      final emojis = foodCategory[categoryName];
      if (emojis == null) {
        logger.w(
          'Unknown category passed to sequential posts: '
          '"$categoryName". No posts will match.',
        );
      }
      foodEmojis = emojis ?? <String>[];
    } else {
      foodEmojis = null;
    }
    final sorted = [...data]..sort((a, b) {
        final aId = (a['id'] as num).toInt();
        final bId = (b['id'] as num).toInt();
        return newer ? aId.compareTo(bId) : bId.compareTo(aId);
      });
    final seen = <int>{};
    final picked = <Posts>[];
    for (final row in sorted) {
      final id = (row['id'] as num).toInt();
      if (newer ? id <= currentPostId : id >= currentPostId) {
        continue;
      }
      if (foodEmojis != null) {
        final tag = row['food_tag'] as String? ?? '';
        final postTags = parseFoodTagIds(tag);
        if (!postTags.any(foodEmojis.contains)) {
          continue;
        }
      }
      if (!seen.add(id)) {
        continue;
      }
      final userId = row['user_id'] as String? ?? '';
      if (blockList.contains(userId)) {
        continue;
      }
      picked.add(Posts.fromJson(row));
      if (picked.length >= limit) {
        break;
      }
    }
    return picked;
  }

  Future<List<Posts>> _userPostItems({
    required String userId,
    required int cursorId,
    required bool newer,
    required int limit,
  }) async {
    final service = ref.read(detailPostServiceProvider.notifier);
    final rows = await service.getPostsFromUserPaged(
      userId,
      limit: limit,
      beforeId: newer ? null : cursorId,
      afterId: newer ? cursorId : null,
    );
    return rows.map(Posts.fromJson).toList();
  }

  Future<List<Posts>> _relatedPostItems({
    required int currentPostId,
    required double lat,
    required double lng,
    required bool newer,
    required int limit,
    required DateTime createdAt,
  }) async {
    final service = ref.read(detailPostServiceProvider.notifier);
    final result = await service.getRelatedPosts(
      currentPostId: currentPostId,
      lat: lat,
      lng: lng,
      limit: limit,
      beforeCreatedAt: newer ? null : createdAt,
      afterCreatedAt: newer ? createdAt : null,
    );
    return result.when(
      success: (data) {
        final blockList =
            ref.read(blockListProvider).asData?.value ?? const <String>[];
        return data
            .where(
              (row) => !blockList.contains(row['user_id'] as String? ?? ''),
            )
            .map(Posts.fromJson)
            .toList();
      },
      failure: (_) => const [],
    );
  }

  Future<List<Posts>> _restaurantPosts(String name) async {
    final postRepo = ref.read(fetchPostRepositoryProvider.notifier);
    final result = await postRepo.getByRestaurantName(restaurant: name);
    return result.when(
      success: (posts) {
        final sorted = [...posts]..sort((a, b) {
            final created = b.createdAt.compareTo(a.createdAt);
            if (created != 0) {
              return created;
            }
            return b.id.compareTo(a.id);
          });
        return sorted;
      },
      failure: (_) => const [],
    );
  }

  Future<List<Posts>> _storedPosts() async {
    final storeList = await Preference().getStringList(PreferenceKey.storeList);
    if (storeList.isEmpty) {
      return const [];
    }
    final idOrder = storeList.map(int.tryParse).whereType<int>().toList()
      ..sort((a, b) => b.compareTo(a));
    if (idOrder.isEmpty) {
      return const [];
    }
    final postRepo = ref.read(fetchPostRepositoryProvider.notifier);
    final storedPostsResult = await postRepo.getStoredPosts(storeList);
    return storedPostsResult.when(
      success: (posts) {
        final mapById = {for (final post in posts) post.id: post};
        return idOrder
            .map((id) => mapById[id])
            .whereType<Posts>()
            .toList(growable: false);
      },
      failure: (_) => const [],
    );
  }
}
