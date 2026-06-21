import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/core/theme/memory_album_theme.dart';
import 'package:food_gram_app/core/utils/helpers/dialog_helper.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/memory_album_utils.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_error_widget.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/screen/memory_album/components/memory_album_detail_header.dart';
import 'package:food_gram_app/ui/screen/memory_album/components/memory_album_post_tile.dart';
import 'package:food_gram_app/ui/screen/memory_album/memory_album_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MemoryAlbumDetailScreen extends HookConsumerWidget {
  const MemoryAlbumDetailScreen({required this.albumId, super.key});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final albumAsync = ref.watch(memoryAlbumDetailViewModelProvider(albumId));
    final sort = useState(MemoryAlbumPostSort.newest);

    return albumAsync.when(
      loading: () => Scaffold(
        backgroundColor: isDark
            ? Theme.of(context).scaffoldBackgroundColor
            : MemoryAlbumTheme.creamBackground,
        body: const Center(child: AppContentLoading()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: AppErrorWidget(
          onTap: () => ref
              .read(memoryAlbumDetailViewModelProvider(albumId).notifier)
              .reload(),
        ),
      ),
      data: (album) {
        if (album == null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(child: Text(t.memoryAlbum.notFound)),
          );
        }

        final postsAsync = ref.watch(memoryAlbumPostsProvider(album.postIds));

        Future<void> deleteAlbum() async {
          DialogHelper().openDialog(
            context: context,
            title: t.memoryAlbum.deleteTitle,
            text: t.memoryAlbum.deleteBody,
            onTap: () async {
              context.pop();
              await ref
                  .read(memoryAlbumListViewModelProvider.notifier)
                  .deleteAlbum(albumId);
              if (context.mounted) {
                SnackBarHelper().openSuccessSnackBar(
                  context,
                  t.memoryAlbum.deleted,
                  '',
                );
                context.pop();
              }
            },
          );
        }

        return Scaffold(
          backgroundColor: isDark
              ? Theme.of(context).scaffoldBackgroundColor
              : MemoryAlbumTheme.creamBackground,
          body: postsAsync.when(
            loading: () => const Center(child: AppContentLoading()),
            error: (_, __) => AppErrorWidget(
              onTap: () =>
                  ref.invalidate(memoryAlbumPostsProvider(album.postIds)),
            ),
            data: (posts) {
              final range = postDateRange(posts);
              final rangeText = formatAlbumDateRange(range.start, range.end);
              final sorted = sortAlbumPosts(posts, sort.value);

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: isDark
                        ? Theme.of(context).colorScheme.surface
                        : MemoryAlbumTheme.creamBackground,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    title: Text(
                      album.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 22),
                        onPressed: () async {
                          await context.pushNamed(
                            RouterPath.memoryAlbumEdit,
                            extra: albumId,
                          );
                          await ref
                              .read(
                                memoryAlbumDetailViewModelProvider(albumId)
                                    .notifier,
                              )
                              .reload();
                          ref.invalidate(
                            memoryAlbumPostsProvider(album.postIds),
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, size: 24),
                        onSelected: (value) {
                          if (value == 'delete') {
                            deleteAlbum();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(t.memoryAlbum.deleteTitle),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: MemoryAlbumDetailHeader(
                      album: album,
                      posts: posts,
                      rangeText: rangeText,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.memoryAlbum.postsSectionTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : Colors.black.withValues(alpha: 0.08),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<MemoryAlbumPostSort>(
                                value: sort.value,
                                isDense: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: MemoryAlbumPostSort.newest,
                                    child: Text(t.memoryAlbum.sortNewest),
                                  ),
                                  DropdownMenuItem(
                                    value: MemoryAlbumPostSort.oldest,
                                    child: Text(t.memoryAlbum.sortOldest),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    sort.value = value;
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (sorted.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text(t.emptyPosts)),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = sorted[index];
                          return MemoryAlbumPostTile(
                            post: post,
                            onTap: () {
                              EasyDebounce.debounce(
                                'memory_album_post_tap',
                                const Duration(milliseconds: 200),
                                () async {
                                  final result = await ref
                                      .read(
                                        detailPostRepositoryProvider.notifier,
                                      )
                                      .getPostData(sorted, index);
                                  await result.whenOrNull(
                                    success: (model) async {
                                      if (!context.mounted) {
                                        return;
                                      }
                                      await context.pushNamed(
                                        RouterPath.myProfileDetail,
                                        extra: model,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                        childCount: sorted.length,
                      ),
                    ),
                  const SliverGap(24),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
