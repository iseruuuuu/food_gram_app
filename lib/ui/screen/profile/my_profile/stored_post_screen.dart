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
    final scrollController = useScrollController();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          l10n.savedPosts,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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
          return CustomScrollView(
            controller: scrollController,
            slivers: [
              AppListView(
                posts: posts,
                routerPath: RouterPath.storedPostDetail,
                type: AppListViewType.stored,
                controller: scrollController,
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
