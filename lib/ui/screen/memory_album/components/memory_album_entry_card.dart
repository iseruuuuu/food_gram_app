import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/memory_album_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/screen/memory_album/components/memory_album_cover_collage.dart';
import 'package:food_gram_app/ui/screen/memory_album/memory_album_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// マイページのアルバム入口カード
class MemoryAlbumEntryCard extends ConsumerWidget {
  const MemoryAlbumEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final albumsAsync = ref.watch(memoryAlbumListViewModelProvider);
    final firstAlbum = albumsAsync.valueOrNull?.isNotEmpty ?? false
        ? albumsAsync.valueOrNull!.first
        : null;
    final previewAsync = firstAlbum == null
        ? null
        : ref.watch(memoryAlbumPostsProvider(firstAlbum.postIds));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pushNamed(RouterPath.memoryAlbumList),
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: MemoryAlbumTheme.cardDecoration(isDark: isDark),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.photo_album_outlined,
                            size: 20,
                            color: isDark
                                ? Colors.amber.shade200
                                : Colors.amber.shade800,
                          ),
                          const Gap(6),
                          Expanded(
                            child: Text(
                              t.memoryAlbum.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        t.memoryAlbum.entrySubtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: previewAsync?.when(
                        data: (posts) => MemoryAlbumCoverCollage(
                          posts: posts,
                          size: 72,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => Icon(
                          Icons.photo_library_outlined,
                          color: isDark ? Colors.white38 : Colors.black26,
                        ),
                      ) ??
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 36,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
