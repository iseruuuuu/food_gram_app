import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/memory_album/components/memory_album_cover_collage.dart';
import 'package:gap/gap.dart';

/// 詳細画面ヘッダー：左コラージュ + 右説明・統計
class MemoryAlbumDetailHeader extends StatelessWidget {
  const MemoryAlbumDetailHeader({
    required this.album,
    required this.posts,
    required this.rangeText,
    super.key,
  });

  final MemoryAlbum album;
  final List<Posts> posts;
  final String rangeText;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final postCountLabel = t.memoryAlbum.postCount.replaceAll(
      '{count}',
      album.postCount.toString(),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MemoryAlbumCoverCollage(
            posts: posts,
            size: 108,
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (album.description.isNotEmpty)
                  Text(
                    album.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                if (album.description.isNotEmpty) const Gap(14),
                _StatLine(
                  icon: Icons.photo_library_outlined,
                  label: postCountLabel,
                  isDark: isDark,
                ),
                if (rangeText.isNotEmpty) ...[
                  const Gap(6),
                  _StatLine(
                    icon: Icons.calendar_today_outlined,
                    label: rangeText,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
        const Gap(6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
