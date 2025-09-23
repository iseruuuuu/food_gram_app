import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/supabase/post/repository/fetch_post_repository.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/stored_post_state.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'stored_post_view_model.g.dart';

@riverpod
class StoredPostViewModel extends _$StoredPostViewModel {
  @override
  StoredPostState build() {
    return const StoredPostState.loading();
  }

  final logger = Logger();

  Future<void> loadStoredPosts() async {
    state = const StoredPostState.loading();

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPostIds =
          prefs.getStringList(PreferenceKey.storeList.name) ?? [];
      if (storedPostIds.isEmpty) {
        state = const StoredPostState.data(posts: []);
        return;
      }
      final result = await ref
          .read(fetchPostRepositoryProvider.notifier)
          .getStoredPosts(storedPostIds);
      result.when(
        success: (posts) {
          state = StoredPostState.data(posts: posts);
        },
        failure: (error) {
          logger.e('Failed to load stored posts: $error');
          state = const StoredPostState.error();
        },
      );
    } on Exception catch (error) {
      logger.e('Error loading stored posts: $error');
      state = const StoredPostState.error();
    }
  }
}
