import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/theme/memory_album_theme.dart';
import 'package:food_gram_app/core/utils/memory_album_utils.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/memory_album/components/memory_album_cover_collage.dart';
import 'package:food_gram_app/ui/screen/memory_album/memory_album_view_model.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MemoryAlbumCard extends ConsumerWidget {
  const MemoryAlbumCard({
    required this.album,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  final MemoryAlbum album;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final postsAsync = ref.watch(memoryAlbumPostsProvider(album.postIds));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: MemoryAlbumTheme.cardDecoration(isDark: isDark),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                postsAsync.when(
                  data: (posts) => MemoryAlbumCoverCollage(posts: posts),
                  loading: () => SizedBox(
                    width: 88,
                    height: 88,
                    child: ColoredBox(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                  error: (_, __) => const SizedBox(
                    width: 88,
                    height: 88,
                    child: Icon(Icons.photo_album_outlined),
                  ),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        t.memoryAlbum.postCount.replaceAll(
                          '{count}',
                          album.postCount.toString(),
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      postsAsync.maybeWhen(
                        data: (posts) {
                          final range = postDateRange(posts);
                          final rangeText =
                              formatAlbumDateRange(range.start, range.end);
                          if (rangeText.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              rangeText,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),
                      if (album.description.isNotEmpty) ...[
                        const Gap(8),
                        Text(
                          album.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onDelete != null)
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_horiz,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete!();
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
          ),
        ),
      ),
    );
  }
}
