import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_error_widget.dart';
import 'package:food_gram_app/ui/component/common/app_list_view.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/stored_post_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StoredPostScreen extends HookConsumerWidget {
  const StoredPostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(storedPostViewModelProvider.notifier).loadStoredPosts();
        });
        return null;
      },
      [],
    );
    final l10n = L10n.of(context);
    final state = ref.watch(storedPostViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savedPosts),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: AppContentLoading()),
        data: (posts) {
          if (posts.isEmpty) {
            return const AppFavoritePostEmpty();
          }
          final data = posts
              .map(
                (post) => {
                  'id': post.id,
                  'food_image': post.foodImage,
                  'user_id': post.userId,
                  'food_name': post.foodName,
                  'comment': post.comment,
                  'heart': post.heart,
                },
              )
              .toList();
          return CustomScrollView(
            slivers: [
              AppListView(
                data: data,
                routerPath: RouterPath.myProfileDetail,
                refresh: () => ref
                    .read(storedPostViewModelProvider.notifier)
                    .loadStoredPosts(),
              ),
            ],
          );
        },
        error: () => AppErrorWidget(
          onTap: () =>
              ref.read(storedPostViewModelProvider.notifier).loadStoredPosts(),
        ),
      ),
    );
  }
}
