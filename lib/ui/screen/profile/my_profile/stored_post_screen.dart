import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_list_view.dart';
import 'package:food_gram_app/ui/component/common/app_tab_error.dart';
import 'package:food_gram_app/ui/component/loading/app_skeleton.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/stored_post_view_model.dart';
import 'package:food_gram_app/ui/screen/tab/tab_state.dart';
import 'package:food_gram_app/ui/screen/tab/tab_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StoredPostScreen extends StatelessWidget {
  const StoredPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surface,
        title: Text(
          Translations.of(context).stored.savedPosts,
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
      body: const _StoredPostContent(logOpenEvent: true),
    );
  }
}

/// 保存した投稿の一覧。IndexedStack でも状態を保てるよう同一ファイル内で共有する。
class _StoredPostContent extends HookConsumerWidget {
  const _StoredPostContent({
    this.logOpenEvent = false,
  });

  final bool logOpenEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(storedPostListProvider);
    void reloadPosts() {
      ref.invalidate(storedPostListProvider);
    }

    final scrollController = useScrollController();
    useEffect(
      () {
        if (logOpenEvent) {
          ref
              .read(firebaseAnalyticsServiceProvider)
              .logEventUnawaited(name: AnalyticsEvent.savedPostOpen);
        }
        return null;
      },
      const [],
    );

    return listAsync.when(
      loading: () => const AppListViewSkeleton(),
      data: (posts) {
        if (posts.isEmpty) {
          return AppFavoritePostEmpty(
            onBrowseTap: () {
              ref.read(tabViewModelProvider().notifier).onTap(TabIndex.home);
              if (context.mounted) {
                context.pop();
              }
            },
          );
        }
        return CustomScrollView(
          controller: scrollController,
          slivers: [
            AppListView(
              posts: posts,
              routerPath: RouterPath.storedPostDetail,
              type: AppListViewType.stored,
              controller: scrollController,
              refresh: reloadPosts,
            ),
          ],
        );
      },
      error: (_, __) => AppTabError.myPage(onRetry: reloadPosts),
    );
  }
}

/// 行きたいリストの IndexedStack 用。別ファイルに切り出さずここから公開する。
class WantToGoStoredPostTab extends StatelessWidget {
  const WantToGoStoredPostTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StoredPostContent();
  }
}
