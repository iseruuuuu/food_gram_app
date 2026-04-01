import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/local/providers/save_album_notifier.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_error_widget.dart';
import 'package:food_gram_app/ui/component/common/app_list_view.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/modal_sheet/save_album_picker_sheet.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/stored_post_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StoredPostScreen extends HookConsumerWidget {
  const StoredPostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAlbumId = useState<String?>(null);
    final albumsAsync = ref.watch(saveAlbumNotifierProvider);
    final listAsync = ref.watch(storedPostListProvider(selectedAlbumId.value));
    void reloadPosts() {
      ref.invalidate(storedPostListProvider(selectedAlbumId.value));
    }

    final t = Translations.of(context);
    final scrollController = useScrollController();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surface,
        title: Text(
          t.stored.savedPosts,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 48,
            child: albumsAsync.when(
              data: (albums) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6, top: 8),
                      child: FilterChip(
                        label: Text(t.stored.albumAll),
                        selected: selectedAlbumId.value == null,
                        onSelected: (_) {
                          selectedAlbumId.value = null;
                        },
                      ),
                    ),
                    for (final a in albums)
                      Padding(
                        padding: const EdgeInsets.only(right: 6, top: 8),
                        child: FilterChip(
                          label: Text(
                            a.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: selectedAlbumId.value == a.id,
                          onSelected: (_) {
                            selectedAlbumId.value = a.id;
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 4),
                      child: IconButton(
                        tooltip: t.stored.albumNew,
                        onPressed: () async {
                          await showCreateAlbumDialog(context: context);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const Gap(12),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: AppContentLoading()),
              data: (posts) {
                if (posts.isEmpty) {
                  return const AppFavoritePostEmpty();
                }
                return CustomScrollView(
                  key: ValueKey<String>(
                    'stored_grid_${selectedAlbumId.value ?? 'all'}',
                  ),
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
              error: (_, __) => AppErrorWidget(
                onTap: reloadPosts,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
