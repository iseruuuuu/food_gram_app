import 'package:flutter/foundation.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/supabase/post/services/delete_service.dart';
import 'package:food_gram_app/core/supabase/post/services/detail_post_service.dart';
import 'package:food_gram_app/core/supabase/post/services/post_service.dart';
import 'package:food_gram_app/core/utils/helpers/url_launch_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/ui/screen/post_detail/post_detail_state.dart';
import 'package:logger/logger.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_detail_view_model.g.dart';

@riverpod
class PostDetailViewModel extends _$PostDetailViewModel {
  @override
  PostDetailState build({
    PostDetailState initState = const PostDetailState(),
  }) {
    return initState;
  }

  Loading get loading => ref.read(loadingProvider.notifier);
  final preference = Preference();
  final logger = Logger();

  /// 投稿の保存状態を初期化時にチェック
  Future<void> initializeStoreState(int postId) async {
    final storeList = await preference.getStringList(PreferenceKey.storeList);
    final isAlreadyStored = storeList.contains(postId.toString());
    state = state.copyWith(isStore: isAlreadyStored);
  }

  /// いいね状態を初期化時にチェック
  Future<void> initializeHeartState(int postId, int initialHeart) async {
    final heartList = await preference.getStringList(PreferenceKey.heartList);
    final isAlreadyHearted = heartList.contains(postId.toString());
    state = state.copyWith(
      heart: initialHeart,
      heartList: heartList,
      isHeart: isAlreadyHearted,
    );
  }

  /// いいね処理
  Future<void> handleHeart({
    required Posts posts,
    required String currentUser,
    required String userId,
    required VoidCallback? onHeartLimitReached,
  }) async {
    if (userId == currentUser) {
      return;
    }

    final postId = posts.id.toString();
    final currentHeart = state.heart;
    final supabase = ref.read(supabaseProvider);

    if (state.isHeart) {
      // いいねを外す場合は制限チェック不要
      await supabase.from('posts').update({
        'heart': currentHeart - 1,
      }).match({'id': posts.id});
      state = state.copyWith(
        heart: currentHeart - 1,
        isHeart: false,
        isAppearHeart: false,
        heartList: List.from(state.heartList)..remove(postId),
      );
    } else {
      // 10回以上いいねした場合は制限
      final canLike = await preference.canLike();
      if (!canLike) {
        onHeartLimitReached?.call();
        return;
      }
      await supabase.from('posts').update({
        'heart': currentHeart + 1,
      }).match({'id': posts.id});
      state = state.copyWith(
        heart: currentHeart + 1,
        isHeart: true,
        isAppearHeart: true,
        heartList: List.from(state.heartList)..add(postId),
      );
      // いいねカウントを増加
      await preference.incrementHeartCount();
    }

    await preference.setStringList(
      PreferenceKey.heartList,
      state.heartList,
    );
  }

  Future<bool> delete(Posts posts) async {
    loading.state = true;
    final result = await ref.read(deleteServiceProvider.notifier).delete(posts);
    await result.when(
      success: (_) async {
        state = state.copyWith(isSuccess: true);
        ref
          ..invalidate(postsStreamProvider)
          ..invalidate(blockListProvider);
      },
      failure: (_) {
        state = state.copyWith(isSuccess: false);
      },
    );
    loading.state = false;
    return state.isSuccess;
  }

  Future<bool> block(String userId) async {
    loading.state = true;
    final blockList = await preference.getStringList(PreferenceKey.blockList);
    blockList.add(userId);
    await Preference().setStringList(PreferenceKey.blockList, blockList);
    await Future<void>.delayed(const Duration(seconds: 2));
    loading.state = false;
    return true;
  }

  Future<void> store({
    required int postId,
    required VoidCallback openSnackBar,
  }) async {
    if (state.isStore) {
      final storeList = await preference.getStringList(PreferenceKey.storeList);
      storeList.remove(postId.toString());
      await preference.setStringList(PreferenceKey.storeList, storeList);
      state = state.copyWith(isStore: false);
    } else {
      final storeList = await preference.getStringList(PreferenceKey.storeList);
      if (!storeList.contains(postId.toString())) {
        storeList.add(postId.toString());
        await preference.setStringList(PreferenceKey.storeList, storeList);
      }
      state = state.copyWith(isStore: true);
      openSnackBar();
    }
  }

  void openUrl(String restaurant) {
    LaunchUrlHelper().open(URL.search(restaurant));
  }

  Future<void> openMap(
    String restaurant,
    double lat,
    double lng,
    VoidCallback? openSnackBar,
  ) async {
    final availableMaps = await MapLauncher.installedMaps;
    if (availableMaps.isEmpty) {
      openSnackBar?.call();
      return;
    }
    await availableMaps.first.showMarker(
      coords: Coords(lat, lng),
      title: restaurant,
    );
  }

  /// スクロール時に新しい投稿を取得
  Future<void> fetchMorePosts() async {
    // 現在の投稿リストを取得
    final currentPosts = state.posts;
    if (currentPosts.isEmpty) {
      return;
    }
    // 新しい投稿を取得
    final result = await ref
        .read(detailPostRepositoryProvider.notifier)
        .getSequentialPosts(
          currentPostId: currentPosts.last.id,
        );

    result.when(
      success: (newPosts) {
        // 新しい投稿をリストに追加
        state = state.copyWith(
          posts: [...currentPosts, ...newPosts.map((model) => model.posts)],
        );
      },
      failure: (error) {
        // エラーハンドリング
        logger.e('Failed to fetch more posts: $error');
      },
    );
  }

  /// ユーザーデータを取得
  //TODO できればここもRepositoryに移行したい
  Future<Map<String, dynamic>> getUserData(String userId) async {
    return ref.read(detailPostServiceProvider.notifier).getUserData(userId);
  }
}

@riverpod
class PostsViewModel extends _$PostsViewModel {
  @override
  PostState build(int postId) {
    getData(postId);
    return const PostState.loading();
  }

  final logger = Logger();

  Future<void> getData(int postId) async {
    state = const PostState.loading();
    try {
      final result =
          await ref.read(detailPostRepositoryProvider.notifier).getPost(postId);
      result.when(
        success: (posts) {
          state = PostState.data(posts: posts);
        },
        failure: (error) {
          state = const PostState.error();
        },
      );
    } on Exception catch (error) {
      logger.e(error);
      state = const PostState.error();
    }
  }

  void setUser(Posts posts) {
    state.whenOrNull(
      data: (posts) {
        state = PostState.data(posts: posts);
      },
    );
  }
}

/// 投稿詳細のリストを type に応じて出し分け
/// mode: 'timeline' | 'myprofile' | 'profile' | 'nearby' | 'search'
@immutable
class PostDetailListArgs {
  const PostDetailListArgs({
    required this.initialPost,
    required this.mode,
    this.profileUserId,
    this.restaurant,
  });
  final Posts initialPost;
  final String mode;
  final String? profileUserId; // profile 用
  final String? restaurant; // search 用

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PostDetailListArgs &&
            other.mode == mode &&
            other.profileUserId == profileUserId &&
            other.restaurant == restaurant &&
            other.initialPost.id == initialPost.id;
  }

  @override
  int get hashCode => Object.hash(
        mode,
        profileUserId,
        restaurant,
        initialPost.id,
      );
}

final postDetailListFutureProvider =
    FutureProvider.family<List<Posts>, PostDetailListArgs>((ref, args) async {
  final detailRepo = ref.read(detailPostRepositoryProvider.notifier);
  final postRepo = ref.read(postRepositoryProvider.notifier);
  switch (args.mode) {
    case 'timeline':
      {
        final r = await detailRepo.getSequentialPosts(
            currentPostId: args.initialPost.id);
        return r.when(
          success: (models) => [
            args.initialPost,
            ...models.map((m) => m.posts),
          ],
          failure: (_) => [args.initialPost],
        );
      }
    case 'myprofile':
      {
        final currentUser = ref.watch(currentUserProvider);
        if (currentUser == null) {
          return [args.initialPost];
        }
        final r = await postRepo.getPostsFromUser(currentUser);
        return r.when(
          success: (posts) {
            final sorted = [...posts]
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final others = sorted
                .where((p) => p.id != args.initialPost.id)
                .toList(growable: false);
            return [args.initialPost, ...others];
          },
          failure: (_) => [args.initialPost],
        );
      }
    case 'profile':
      {
        final userId = args.profileUserId;
        if (userId == null || userId.isEmpty) {
          return [args.initialPost];
        }
        final r = await postRepo.getPostsFromUser(userId);
        return r.when(
          success: (posts) {
            final sorted = [...posts]
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final others = sorted
                .where((p) => p.id != args.initialPost.id)
                .toList(growable: false);
            return [args.initialPost, ...others];
          },
          failure: (_) => [args.initialPost],
        );
      }
    case 'nearby':
      {
        final r = await detailRepo.getRelatedPosts(
          currentPostId: args.initialPost.id,
          lat: args.initialPost.lat,
          lng: args.initialPost.lng,
          limit: 20,
        );
        return r.when(
          success: (models) => [
            args.initialPost,
            ...models.map((m) => m.posts),
          ],
          failure: (_) => [args.initialPost],
        );
      }
    case 'search':
      {
        final restaurant = args.restaurant ?? args.initialPost.restaurant;
        final r = await postRepo.getByRestaurantName(restaurant: restaurant);
        return r.when(
          success: (posts) {
            final others = posts
                .where((p) => p.id != args.initialPost.id)
                .toList(growable: false);
            return [args.initialPost, ...others];
          },
          failure: (_) => [args.initialPost],
        );
      }
    default:
      return [args.initialPost];
  }
});
