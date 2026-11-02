import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/post_deail_list_mode.dart';
import 'package:food_gram_app/core/model/post_detail_feed.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/post_visibility.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/fetch_post_repository.dart';
import 'package:food_gram_app/core/supabase/post/services/detail_post_service.dart';
import 'package:food_gram_app/core/supabase/post/visible_page.dart';
import 'package:food_gram_app/core/supabase/user/providers/friend_user_ids_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'detail_post_repository.g.dart';

DateTime? _relatedCreatedAt(Object? value) {
  if (value is DateTime) {
    return value.toUtc();
  }
  if (value is String) {
    return DateTime.tryParse(value)?.toUtc();
  }
  return null;
}

bool _sameRelatedInstant(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.toUtc().microsecondsSinceEpoch == b.toUtc().microsecondsSinceEpoch;
}

/// 時系列詳細の1方向分。近い順。
class _SequentialSlice {
  const _SequentialSlice({
    required this.posts,
    required this.hasMore,
  });

  final List<Posts> posts;
  final bool hasMore;
}

@Riverpod(keepAlive: true)
class DetailPostRepository extends _$DetailPostRepository {
  @override
  Future<void> build() async {}
  final logger = Logger();

  /// 特定の投稿を取得
  Future<Result<Posts, Exception>> getPost(int postId) async {
    try {
      final service = ref.read(detailPostServiceProvider.notifier);
      final result = await service.getPost(postId);
      return await result.when(
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
  Future<Map<String, dynamic>> getUserData(String userId) {
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
      final fetchLimit = (categoryName != null && categoryName.isNotEmpty)
          ? 50
          : limit;
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
          final sorted = [...data]
            ..sort(
              (a, b) => ((b['id'] as num).toInt()).compareTo(
                (a['id'] as num).toInt(),
              ),
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
          final models = await _modelsFromPostRows(filtered);
          return Success<List<Model>, Exception>(models);
        },
        failure: Failure<List<Model>, Exception>.new,
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
      final rows = await _visibleRelatedRows(
        currentPostId: currentPostId,
        lat: lat,
        lng: lng,
        limit: 10,
      );
      final models = await _modelsFromPostRows(rows);
      return Success<List<Model>, Exception>(models);
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
      case PostDetailListMode.friends:
        return _friendsFeed(
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
          return takePostsAround(
            sortedNewestFirst: ordered,
            initial: initialPost,
          );
        }
    }
  }

  /// 投稿詳細フィードの追加ページを取得する
  Future<PostDetailPageResult> getPostDetailPage({
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
        return _sequentialDetailPage(
          cursorPost: cursorPost,
          newer: isNewer,
          limit: limit,
          categoryName: categoryName,
        );
      case PostDetailListMode.friends:
        {
          final friendIds = await _friendFeedUserIds();
          if (friendIds.isEmpty) {
            return const PostDetailPageResult(posts: [], hasMore: false);
          }
          return _sequentialDetailPage(
            cursorPost: cursorPost,
            newer: isNewer,
            limit: limit,
            categoryName: categoryName,
            userIds: friendIds,
          );
        }
      case PostDetailListMode.myprofile:
        {
          final currentUser = ref.watch(currentUserProvider);
          if (currentUser == null) {
            return const PostDetailPageResult(posts: [], hasMore: false);
          }
          final posts = await _userPostItems(
            userId: currentUser,
            cursorId: cursorPost.id,
            newer: isNewer,
            limit: limit,
          );
          return _countedPage(posts, limit);
        }
      case PostDetailListMode.profile:
        {
          final userId = profileUserId;
          if (userId == null || userId.isEmpty) {
            return const PostDetailPageResult(posts: [], hasMore: false);
          }
          final posts = await _userPostItems(
            userId: userId,
            cursorId: cursorPost.id,
            newer: isNewer,
            limit: limit,
          );
          return _countedPage(posts, limit);
        }
      case PostDetailListMode.nearby:
        {
          final posts = await _relatedPostItems(
            currentPostId: cursorPost.id,
            lat: cursorPost.lat,
            lng: cursorPost.lng,
            newer: isNewer,
            limit: limit,
            createdAt: cursorPost.createdAt,
          );
          return _countedPage(posts, limit);
        }
      case PostDetailListMode.search:
        {
          final name = restaurant ?? cursorPost.restaurant;
          final posts = await _restaurantPosts(name);
          final page = isNewer
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
          return _countedPage(page, limit);
        }
      case PostDetailListMode.stored:
        {
          final ordered = await _storedPosts();
          final page = isNewer
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
          return _countedPage(page, limit);
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

  Future<List<String>> _friendFeedUserIds() async {
    final viewerId = ref.read(currentUserProvider);
    final friendIds = await ref.read(friendUserIdsProvider.future);
    return friendIds
        .where((id) => id.isNotEmpty && id != viewerId)
        .toList(growable: false);
  }

  Future<PostDetailListResult> _friendsFeed({
    required Posts initialPost,
    String? categoryName,
  }) async {
    final friendIds = await _friendFeedUserIds();
    if (friendIds.isEmpty) {
      return _single(initialPost);
    }
    return _timelineFeed(
      initialPost: initialPost,
      categoryName: categoryName,
      userIds: friendIds,
    );
  }

  Future<PostDetailListResult> _timelineFeed({
    required Posts initialPost,
    String? categoryName,
    List<String>? userIds,
  }) async {
    final newerFuture = _sequentialPostItems(
      currentPostId: initialPost.id,
      newer: true,
      limit: postDetailNewerPageSize,
      categoryName: categoryName,
      userIds: userIds,
    );
    final olderFuture = _sequentialPostItems(
      currentPostId: initialPost.id,
      newer: false,
      limit: postDetailOlderPageSize,
      categoryName: categoryName,
      userIds: userIds,
    );
    final newerClosestFirst = await newerFuture;
    final olderClosestFirst = await olderFuture;
    return PostDetailListResult(
      posts: [
        ...newerClosestFirst.posts.reversed,
        initialPost,
        ...olderClosestFirst.posts,
      ],
      hasMoreNewer: newerClosestFirst.hasMore,
      hasMoreOlder: olderClosestFirst.hasMore,
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

  PostDetailPageResult _countedPage(List<Posts> posts, int limit) {
    return PostDetailPageResult(
      posts: posts,
      hasMore: posts.length >= limit,
    );
  }

  Future<PostDetailPageResult> _sequentialDetailPage({
    required Posts cursorPost,
    required bool newer,
    required int limit,
    String? categoryName,
    List<String>? userIds,
  }) async {
    final slice = await _sequentialPostItems(
      currentPostId: cursorPost.id,
      newer: newer,
      limit: limit,
      categoryName: categoryName,
      userIds: userIds,
    );
    return PostDetailPageResult(
      posts: newer ? slice.posts.reversed.toList() : slice.posts,
      hasMore: slice.hasMore,
    );
  }

  /// カテゴリとブロックを除いたあとで [limit] 件になるまで取得する。
  /// 生のバッチが尽きたときだけ、見える件数が足りなくても終える。
  Future<_SequentialSlice> _sequentialPostItems({
    required int currentPostId,
    required bool newer,
    required int limit,
    String? categoryName,
    List<String>? userIds,
  }) async {
    final hasCategory = categoryName != null && categoryName.isNotEmpty;
    final List<String>? foodEmojis;
    if (hasCategory) {
      final emojis = foodCategory[categoryName];
      if (emojis == null) {
        logger.w(
          'Unknown category passed to sequential posts: '
          '"$categoryName". No posts will match.',
        );
        return const _SequentialSlice(posts: [], hasMore: false);
      }
      foodEmojis = emojis;
    } else {
      foodEmojis = null;
    }
    final service = ref.read(detailPostServiceProvider.notifier);
    final blockList =
        ref.read(blockListProvider).asData?.value ?? const <String>[];
    final page = VisiblePage<Map<String, dynamic>>(limit: limit);
    final seen = <int>{};
    final batchSize = hasCategory ? limit * 5 : limit;
    var cursor = currentPostId;

    while (!page.isComplete) {
      final result = newer
          ? await service.getNewerSequentialPosts(
              currentPostId: cursor,
              limit: batchSize,
              userIds: userIds,
            )
          : await service.getSequentialPosts(
              currentPostId: cursor,
              limit: batchSize,
              userIds: userIds,
            );
      final rows = result.when(
        success: (data) => data,
        failure: (_) => null,
      );
      if (rows == null) {
        page.sourceExhausted = true;
        break;
      }
      final sorted = [...rows]
        ..sort((a, b) {
          final aId = (a['id'] as num).toInt();
          final bId = (b['id'] as num).toInt();
          return newer ? aId.compareTo(bId) : bId.compareTo(aId);
        });
      page.addBatch(
        sorted,
        batchSize: batchSize,
        isVisible: (row) => _isSequentialRowVisible(
          row,
          currentPostId: currentPostId,
          newer: newer,
          foodEmojis: foodEmojis,
          blockList: blockList,
          seen: seen,
        ),
      );
      if (page.isComplete || sorted.isEmpty) {
        break;
      }
      final nextCursor = (sorted.last['id'] as num).toInt();
      if (nextCursor == cursor) {
        page.sourceExhausted = true;
        break;
      }
      cursor = nextCursor;
    }

    return _SequentialSlice(
      posts: page.items.map(Posts.fromJson).toList(growable: false),
      hasMore: !page.sourceExhausted,
    );
  }

  bool _isSequentialRowVisible(
    Map<String, dynamic> row, {
    required int currentPostId,
    required bool newer,
    required List<String>? foodEmojis,
    required List<String> blockList,
    required Set<int> seen,
  }) {
    final id = (row['id'] as num).toInt();
    if (newer ? id <= currentPostId : id >= currentPostId) {
      return false;
    }
    if (foodEmojis != null) {
      final tag = row['food_tag'] as String? ?? '';
      final postTags = parseFoodTagIds(tag);
      if (!postTags.any(foodEmojis.contains)) {
        return false;
      }
    }
    if (!seen.add(id)) {
      return false;
    }
    final userId = row['user_id'] as String? ?? '';
    return !blockList.contains(userId);
  }

  Future<List<Posts>> _userPostItems({
    required String userId,
    required int cursorId,
    required bool newer,
    required int limit,
  }) async {
    try {
      final service = ref.read(detailPostServiceProvider.notifier);
      final rows = await service.getPostsFromUserPaged(
        userId,
        limit: limit,
        beforeId: newer ? null : cursorId,
        afterId: newer ? cursorId : null,
      );
      return rows.map(Posts.fromJson).toList();
    } on PostgrestException catch (e) {
      logger.e('Failed to fetch user posts: ${e.message}');
      return const [];
    }
  }

  Future<List<Posts>> _relatedPostItems({
    required int currentPostId,
    required double lat,
    required double lng,
    required bool newer,
    required int limit,
    required DateTime createdAt,
  }) async {
    final rows = await _visibleRelatedRows(
      currentPostId: currentPostId,
      lat: lat,
      lng: lng,
      limit: limit,
      beforeCreatedAt: newer ? null : createdAt,
      afterCreatedAt: newer ? createdAt : null,
    );
    return rows.map(Posts.fromJson).toList();
  }

  /// ブロックと非公開を除いたあとで [limit] 件になるまで取得する。
  /// 取得元が尽きたときだけ、見える件数が足りなくても終える。
  Future<List<Map<String, dynamic>>> _visibleRelatedRows({
    required int currentPostId,
    required double lat,
    required double lng,
    required int limit,
    DateTime? beforeCreatedAt,
    DateTime? afterCreatedAt,
  }) async {
    final service = ref.read(detailPostServiceProvider.notifier);
    final blockList =
        ref.read(blockListProvider).asData?.value ?? const <String>[];
    final viewerId = ref.read(currentUserProvider);
    final friendIds = await ref.read(friendUserIdsProvider.future);
    final page = VisiblePage<Map<String, dynamic>>(limit: limit);
    final seen = <int>{};
    final newer = afterCreatedAt != null;
    final batchSize = limit < 20 ? 20 : limit;
    var before = beforeCreatedAt;
    var after = afterCreatedAt;
    int? beforeId;
    int? afterId;

    while (!page.isComplete) {
      final result = await service.getRelatedPosts(
        currentPostId: currentPostId,
        lat: lat,
        lng: lng,
        limit: batchSize,
        beforeCreatedAt: before,
        afterCreatedAt: after,
        beforeId: beforeId,
        afterId: afterId,
      );
      final rows = result.when(
        success: (data) => data,
        failure: (_) => const <Map<String, dynamic>>[],
      );
      page.addBatch(
        rows,
        batchSize: batchSize,
        isVisible: (row) {
          final id = (row['id'] as num).toInt();
          if (!seen.add(id)) {
            return false;
          }
          return _isRelatedRowVisible(
            row,
            blockList: blockList,
            viewerId: viewerId,
            friendIds: friendIds,
          );
        },
      );
      if (page.isComplete || rows.isEmpty) {
        break;
      }
      final last = rows.last;
      final lastId = (last['id'] as num).toInt();
      final lastCreated = _relatedCreatedAt(last['created_at']);
      final cursorStuck =
          _sameRelatedInstant(
            newer ? after : before,
            lastCreated,
          ) &&
          (newer ? afterId : beforeId) == lastId;
      if (lastCreated == null || cursorStuck) {
        break;
      }
      if (newer) {
        after = lastCreated;
        afterId = lastId;
      } else {
        before = lastCreated;
        beforeId = lastId;
      }
    }
    return page.items;
  }

  bool _isRelatedRowVisible(
    Map<String, dynamic> row, {
    required List<String> blockList,
    required String? viewerId,
    required List<String> friendIds,
  }) {
    final authorId = row['user_id'] as String? ?? '';
    if (blockList.contains(authorId)) {
      return false;
    }
    return isPostVisibleToViewer(
      isPrivate: row['is_anonymous'] == true,
      authorId: authorId,
      viewerId: viewerId,
      friendUserIds: friendIds,
    );
  }

  Future<List<Posts>> _restaurantPosts(String name) async {
    final postRepo = ref.read(fetchPostRepositoryProvider.notifier);
    final result = await postRepo.getByRestaurantName(restaurant: name);
    return result.when(
      success: (posts) {
        final sorted = [...posts]
          ..sort((a, b) {
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

  Future<List<Model>> _modelsFromPostRows(
    List<Map<String, dynamic>> rows,
  ) async {
    final userIds = rows
        .map((row) => row['user_id'] as String?)
        .whereType<String>();
    final usersById = await ref
        .read(detailPostServiceProvider.notifier)
        .getUsersData(userIds);
    final models = <Model>[];
    for (final row in rows) {
      final userId = row['user_id'] as String?;
      final userData = userId == null ? null : usersById[userId];
      if (userData == null) {
        continue;
      }
      models.add(Model(Users.fromJson(userData), Posts.fromJson(row)));
    }
    return models;
  }
}
