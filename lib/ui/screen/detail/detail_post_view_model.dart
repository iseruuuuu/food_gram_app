import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/supabase/post/services/delete_service.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/ui/screen/detail/detail_post_state.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_post_view_model.g.dart';

@riverpod
class DetailPostViewModel extends _$DetailPostViewModel {
  @override
  DetailPostState build({
    DetailPostState initState = const DetailPostState(),
  }) {
    return initState;
  }

  Loading get loading => ref.read(loadingProvider.notifier);
  final preference = Preference();

  Future<bool> delete(Posts posts) async {
    loading.state = true;
    final result = await ref.read(deleteServiceProvider.notifier).delete(posts);
    await result.when(
      success: (_) async {
        state = state.copyWith(isSuccess: true);
        ref
          ..invalidate(postStreamProvider)
          ..invalidate(postHomeMadeStreamProvider)
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
