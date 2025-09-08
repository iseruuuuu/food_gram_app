import 'package:flutter/foundation.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/supabase/post/services/delete_service.dart';
import 'package:food_gram_app/core/utils/helpers/url_launch_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/ui/screen/post_detail/post_detail_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
          ..invalidate(postStreamProvider)
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
          await ref.read(postRepositoryProvider.notifier).getPost(postId);
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

/// 投稿詳細画面のリスト用プロバイダー（ID順）
@riverpod
Future<List<Posts>> postDetailList(Ref ref, Posts initialPost) async {
  final result =
      await ref.read(postRepositoryProvider.notifier).getSequentialPosts(
            currentPostId: initialPost.id,
            limit: 20,
          );

  return result.when(
    success: (models) {
      // 初期投稿を先頭に配置し、ID順の投稿を追加
      return [initialPost, ...models.map((model) => model.posts)];
    },
    failure: (error) {
      // エラーの場合は初期投稿のみ返す
      return [initialPost];
    },
  );
}
