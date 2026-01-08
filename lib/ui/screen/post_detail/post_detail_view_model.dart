import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/post_deail_list_mode.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/notification/firebase_messaging_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/delete_repository.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/core/utils/helpers/url_launch_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_map_select_modal_sheet.dart';
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
      // final canLike = await preference.canLike();
      // if (!canLike) {
      //   onHeartLimitReached?.call();
      //   return;
      // }
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

      // 通知を送信（投稿者に通知）
      try {
        // 現在のユーザー名を取得
        final currentUserData = await getUserData(currentUser);
        final likerName = currentUserData['name'] as String? ?? '誰か';

        // 通知を送信
        final firebaseMessagingService = FirebaseMessagingService();
        await firebaseMessagingService.sendHeartNotification(
          postOwnerId: userId,
          postId: posts.id,
          likerName: likerName,
          likerUserId: currentUser,
        );
        logger.i(
          'いいね通知を送信しました: '
          '投稿者ID=$userId, 投稿ID=${posts.id}, いいねした人=$likerName',
        );
      } on Exception catch (e) {
        logger.e('いいね通知の送信に失敗しました: $e');
        // 通知の送信に失敗してもいいね処理は続行
      }
    }

    await preference.setStringList(
      PreferenceKey.heartList,
      state.heartList,
    );
  }

  Future<bool> delete(Posts posts) async {
    loading.state = true;
    final result =
        await ref.read(deleteRepositoryProvider.notifier).deletePost(posts);
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
    final storeList = await preference.getStringList(PreferenceKey.storeList);
    final parsePostId = postId.toString();
    final isCurrentlyStored = storeList.contains(parsePostId);

    if (isCurrentlyStored) {
      storeList.remove(parsePostId);
      await preference.setStringList(PreferenceKey.storeList, storeList);
      state = state.copyWith(isStore: false);
    } else {
      storeList.add(parsePostId);
      await preference.setStringList(PreferenceKey.storeList, storeList);
      state = state.copyWith(isStore: true);
      openSnackBar();
    }
  }

  void openUrl(String restaurant) {
    LaunchUrlHelper().open(URL.search(restaurant));
  }

  void openSelectedMap(
    BuildContext context,
    String restaurant,
    double lat,
    double lng,
    VoidCallback? openSnackBar,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return AppMapSelectModalSheet(
          onMapSelected: (mapType) {
            openMap(
              restaurant: restaurant,
              lat: lat,
              lng: lng,
              mapType: mapType,
              openSnackBar: openSnackBar,
            );
          },
        );
      },
    );
  }

  Future<void> openMap({
    required String restaurant,
    required double lat,
    required double lng,
    required MapType mapType,
    VoidCallback? openSnackBar,
  }) async {
    final isAvailable = await MapLauncher.isMapAvailable(mapType);
    if (isAvailable != true) {
      openSnackBar?.call();
      return;
    }
    await MapLauncher.showMarker(
      mapType: mapType,
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
  Future<Map<String, dynamic>> getUserData(String userId) async {
    return ref.read(detailPostRepositoryProvider.notifier).getUserData(userId);
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

/// 投稿詳細のリストを mode に応じて出し分け
@immutable
class PostDetailListInput {
  const PostDetailListInput({
    required this.initialPost,
    required this.mode,
    this.profileUserId,
    this.restaurant,
  });
  final Posts initialPost;
  final PostDetailListMode mode;
  final String? profileUserId;
  final String? restaurant;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PostDetailListInput &&
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

@riverpod
Future<List<Posts>> postDetailList(
  Ref ref,
  PostDetailListInput listInput,
) async {
  final repository = ref.read(detailPostRepositoryProvider.notifier);
  return repository.getPostDetailList(
    initialPost: listInput.initialPost,
    mode: listInput.mode,
    profileUserId: listInput.profileUserId,
    restaurant: listInput.restaurant,
  );
}
