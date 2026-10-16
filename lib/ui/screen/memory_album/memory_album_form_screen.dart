import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/restaurant/restaurant_display_name.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_tab_error.dart';
import 'package:food_gram_app/ui/component/dialog/app_memory_album_share_dialog.dart';
import 'package:food_gram_app/ui/component/dialog/memory_album_dialog.dart';
import 'package:food_gram_app/ui/component/loading/app_skeleton.dart';
import 'package:food_gram_app/ui/screen/memory_album/memory_album_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MemoryAlbumFormScreen extends HookConsumerWidget {
  const MemoryAlbumFormScreen({this.albumId, super.key});

  final String? albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isEdit = albumId != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleCtrl = useTextEditingController();
    final descCtrl = useTextEditingController();
    final selectedIds = useState<List<int>>(<int>[]);
    final isSaving = useState(false);
    final didPrefill = useRef(false);

    if (isEdit) {
      final albumAsync =
          ref.watch(memoryAlbumDetailViewModelProvider(albumId!));
      useEffect(
        () {
          final album = albumAsync.valueOrNull;
          if (album != null && !didPrefill.value) {
            didPrefill.value = true;
            titleCtrl.text = album.title;
            descCtrl.text = album.description;
            selectedIds.value = List<int>.from(album.postIds);
          }
          return null;
        },
        [albumAsync],
      );
    }

    final myPosts = ref.watch(myPostStreamProvider);

    void openQuickSharePreview(List<Posts> allPosts) {
      if (selectedIds.value.isEmpty) {
        return;
      }
      FocusScope.of(context).unfocus();
      final byId = {for (final p in allPosts) p.id: p};
      final chosen = <Posts>[
        for (final id in selectedIds.value)
          if (byId[id] != null) byId[id]!,
      ];
      if (chosen.isEmpty) {
        return;
      }
      final isJa = Localizations.localeOf(context).languageCode == 'ja';
      final fallbackTitle =
          isJa ? '今月の食の思い出' : 'My Food Memories';
      final now = DateTime.now();
      final tempAlbum = MemoryAlbum(
        id: albumId ?? 'quick_share_preview',
        title: titleCtrl.text.trim().isEmpty
            ? fallbackTitle
            : titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        postIds: selectedIds.value,
        createdAt: now,
        updatedAt: now,
      );
      showGeneralDialog<void>(
        context: context,
        pageBuilder: (_, __, ___) {
          return AppMemoryAlbumShareDialog(
            album: tempAlbum,
            posts: chosen,
          );
        },
      );
    }

    Future<void> save() async {
      if (isSaving.value) {
        return;
      }
      isSaving.value = true;
      try {
        if (isEdit) {
          final error = await ref
              .read(memoryAlbumDetailViewModelProvider(albumId!).notifier)
              .updateAlbum(
                title: titleCtrl.text,
                description: descCtrl.text,
                postIds: selectedIds.value,
              );
          if (!context.mounted) {
            return;
          }
          if (error == null) {
            ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
                  name: AnalyticsEvent.albumEditComplete,
                  parameters: albumId != null
                      ? {AnalyticsParam.albumId: albumId!}
                      : null,
                );
            SnackBarHelper().openSuccessSnackBar(
              context,
              t.memoryAlbum.saved,
              '',
            );
            context.pop();
            return;
          }
          final message = switch (error) {
            MemoryAlbumError.emptyTitle => t.memoryAlbum.emptyTitleError,
            MemoryAlbumError.emptyPostIds => t.memoryAlbum.emptyPostsError,
            MemoryAlbumError.albumNotFound => t.memoryAlbum.notFound,
            MemoryAlbumError.albumLimitFree => t.memoryAlbum.albumLimitBody,
          };
          SnackBarHelper().openErrorSnackBar(context, message, '');
          return;
        }

        final error = await ref
            .read(memoryAlbumListViewModelProvider.notifier)
            .createAlbum(
              title: titleCtrl.text,
              description: descCtrl.text,
              postIds: selectedIds.value,
            );
        if (!context.mounted) {
          return;
        }
        if (error == null) {
          ref
              .read(firebaseAnalyticsServiceProvider)
              .logEventUnawaited(name: AnalyticsEvent.albumCreate);
          SnackBarHelper().openSuccessSnackBar(
            context,
            t.memoryAlbum.saved,
            '',
          );
          context.pop();
          return;
        }
        if (error == MemoryAlbumError.albumLimitFree) {
          final isPremium = await ref.read(isSubscribeProvider.future);
          if (context.mounted) {
            await showMemoryAlbumLimitDialog(
              context,
              isPremium: isPremium,
            );
          }
          return;
        }
        final message = switch (error) {
          MemoryAlbumError.emptyTitle => t.memoryAlbum.emptyTitleError,
          MemoryAlbumError.emptyPostIds => t.memoryAlbum.emptyPostsError,
          MemoryAlbumError.albumNotFound => t.memoryAlbum.notFound,
          MemoryAlbumError.albumLimitFree => t.memoryAlbum.albumLimitBody,
        };
        SnackBarHelper().openErrorSnackBar(context, message, '');
      } finally {
        isSaving.value = false;
      }
    }

    void togglePost(int id) {
      final list = List<int>.from(selectedIds.value);
      if (list.contains(id)) {
        list.remove(id);
      } else {
        list.add(id);
      }
      selectedIds.value = list;
    }

    final postsValue = myPosts.valueOrNull ?? const <Posts>[];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            isEdit ? t.memoryAlbum.edit : t.memoryAlbum.create,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (selectedIds.value.isNotEmpty && postsValue.isNotEmpty)
              IconButton(
                tooltip: t.share.shareButton,
                icon: const Icon(
                  Icons.ios_share,
                  color: AppTheme.primaryOrange,
                  size: 21,
                ),
                onPressed: () => openQuickSharePreview(postsValue),
              ),
            TextButton(
              onPressed:
                  isSaving.value || selectedIds.value.isEmpty ? null : save,
              child: isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      t.save,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedIds.value.isEmpty
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (postsValue.isNotEmpty)
              _QuickPresetChipsBar(
                posts: postsValue,
                onApplyPreset: (presetTitle, ids) {
                  if (titleCtrl.text.trim().isEmpty || !isEdit) {
                    titleCtrl.text = presetTitle;
                  }
                  selectedIds.value = ids;
                },
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: t.memoryAlbum.titleHint,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: t.memoryAlbum.descriptionHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Text(
                    t.memoryAlbum.selectPosts,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  if (selectedIds.value.isNotEmpty)
                    Text(
                      t.memoryAlbum.postCount.replaceAll(
                        '{count}',
                        selectedIds.value.length.toString(),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: myPosts.when(
                loading: () => const AppListViewSkeleton(),
                error: (_, __) => AppTabError.myPage(
                  onRetry: () => ref.invalidate(myPostStreamProvider),
                ),
                data: (posts) {
                  if (posts.isEmpty) {
                    return const AppEmpty();
                  }
                  final supabase = ref.watch(supabaseProvider);
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final selected = selectedIds.value.contains(post.id);
                      final storageKey = post.firstFoodImage;
                      final imageUrl = storageKey.isEmpty
                          ? null
                          : supabase.storage
                              .from('food')
                              .getPublicUrl(storageKey);
                      return GestureDetector(
                        onTap: () => togglePost(post.id),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (imageUrl == null)
                              ColoredBox(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                                child: Icon(
                                  Icons.fastfood,
                                  color:
                                      isDark ? Colors.white54 : Colors.black38,
                                ),
                              )
                            else
                              CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                              ),
                            if (selected)
                              ColoredBox(
                                color: Colors.black.withValues(alpha: 0.35),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            Positioned(
                              left: 4,
                              bottom: 4,
                              right: 4,
                              child: Text(
                                post.localizedDisplayTitle(t),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(blurRadius: 4),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 自分の投稿から「今月のまとめ」「★高評価ベスト」「一番食べたジャンル」をワンタップで自動選択するチップバー
class _QuickPresetChipsBar extends StatelessWidget {
  const _QuickPresetChipsBar({
    required this.posts,
    required this.onApplyPreset,
  });

  final List<Posts> posts;
  final void Function(String title, List<int> postIds) onApplyPreset;

  @override
  Widget build(BuildContext context) {
    final isJa = Localizations.localeOf(context).languageCode == 'ja';
    final now = DateTime.now();
    final sorted = [...posts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final thisMonthPosts = sorted
        .where(
          (p) =>
              p.createdAt.toLocal().year == now.year &&
              p.createdAt.toLocal().month == now.month,
        )
        .take(9)
        .toList();

    final recentTop9 = sorted.take(9).toList();

    final highRated = [...posts]
      ..sort((a, b) {
        final starCmp = b.star.compareTo(a.star);
        if (starCmp != 0) {
          return starCmp;
        }
        return b.heart.compareTo(a.heart);
      });
    final bestPosts = highRated.take(9).toList();

    final traits = analyzeRecordFoodTraits(posts);
    final topGenre = traits.topGenre;
    final topGenreName = topGenre != null
        ? getLocalizedFoodName(topGenre, context)
        : null;
    final genrePosts = topGenre == null
        ? const <Posts>[]
        : sorted
            .where((p) => parseFoodTagIds(p.foodTag).contains(topGenre))
            .take(9)
            .toList();

    final chips = <({
      IconData icon,
      String label,
      String title,
      List<int> ids,
    })>[
      if (thisMonthPosts.isNotEmpty)
        (
          icon: Icons.calendar_month_outlined,
          label: isJa
              ? '今月の思い出 (${thisMonthPosts.length})'
              : 'This Month (${thisMonthPosts.length})',
          title: isJa
              ? '${now.month}月の食の思い出'
              : 'My Food Memories',
          ids: [for (final p in thisMonthPosts) p.id],
        )
      else if (recentTop9.isNotEmpty)
        (
          icon: Icons.auto_awesome_outlined,
          label: isJa
              ? '最近の9選 (${recentTop9.length})'
              : 'Recent Top (${recentTop9.length})',
          title: isJa ? '今月の食の思い出' : 'My Food Memories',
          ids: [for (final p in recentTop9) p.id],
        ),
      if (bestPosts.isNotEmpty)
        (
          icon: Icons.star_rounded,
          label: isJa
              ? '★高評価ベスト (${bestPosts.length})'
              : '★ Best Picks (${bestPosts.length})',
          title: isJa ? 'お気に入りベスト' : 'My Favorite Dishes',
          ids: [for (final p in bestPosts) p.id],
        ),
      if (topGenreName != null && genrePosts.length >= 2)
        (
          icon: Icons.restaurant_menu_rounded,
          label: '$topGenreName (${genrePosts.length})',
          title: isJa ? '$topGenreNameまとめ' : '$topGenreName Collection',
          ids: [for (final p in genrePosts) p.id],
        ),
    ];

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const Gap(8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return ActionChip(
            avatar: Icon(
              chip.icon,
              size: 16,
              color: AppTheme.primaryOrange,
            ),
            label: Text(
              chip.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: AppTheme.orangeBackgroundOf(context),
            side: BorderSide(
              color: AppTheme.primaryOrange.withValues(alpha: 0.4),
            ),
            shape: const StadiumBorder(),
            onPressed: () => onApplyPreset(chip.title, chip.ids),
          );
        },
      ),
    );
  }
}
