import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/memory_album_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 重なり合う写真コラージュ（一覧カード・詳細ヒーロー用）
class MemoryAlbumCoverCollage extends ConsumerWidget {
  const MemoryAlbumCoverCollage({
    required this.posts,
    this.size = 88,
    this.hero = false,
    super.key,
  });

  final List<Posts> posts;
  final double size;
  final bool hero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final preview = postsWithImages(posts, max: hero ? 2 : 3);
    if (preview.isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: ColoredBox(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          child: Icon(
            Icons.fastfood,
            color: isDark ? Colors.white38 : Colors.black26,
            size: size * 0.35,
          ),
        ),
      );
    }

    if (hero) {
      return SizedBox(
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (preview.length > 1)
              Positioned(
                left: size * 0.08,
                child: Transform.rotate(
                  angle: -0.12,
                  child: _PhotoFrame(
                    url: postImageUrl(ref, preview[1]),
                    width: size * 0.72,
                    height: size * 0.72,
                    isDark: isDark,
                  ),
                ),
              ),
            Positioned(
              right: size * 0.08,
              child: Transform.rotate(
                angle: 0.1,
                child: _PhotoFrame(
                  url: postImageUrl(ref, preview.first),
                  width: size * 0.78,
                  height: size * 0.78,
                  isDark: isDark,
                  elevation: 6,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (preview.length > 2)
            Positioned(
              left: 0,
              top: size * 0.12,
              child: Transform.rotate(
                angle: -0.15,
                child: _PhotoFrame(
                  url: postImageUrl(ref, preview[2]),
                  width: size * 0.55,
                  height: size * 0.55,
                  isDark: isDark,
                ),
              ),
            ),
          if (preview.length > 1)
            Positioned(
              left: size * 0.18,
              top: size * 0.04,
              child: Transform.rotate(
                angle: 0.08,
                child: _PhotoFrame(
                  url: postImageUrl(ref, preview[1]),
                  width: size * 0.58,
                  height: size * 0.58,
                  isDark: isDark,
                ),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Transform.rotate(
              angle: -0.05,
              child: _PhotoFrame(
                url: postImageUrl(ref, preview.first),
                width: size * 0.62,
                height: size * 0.62,
                isDark: isDark,
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoFrame extends StatelessWidget {
  const _PhotoFrame({
    required this.url,
    required this.width,
    required this.height,
    required this.isDark,
    this.elevation = 2,
  });

  final String? url;
  final double width;
  final double height;
  final bool isDark;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? ColoredBox(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                child: Icon(
                  Icons.fastfood,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              )
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
