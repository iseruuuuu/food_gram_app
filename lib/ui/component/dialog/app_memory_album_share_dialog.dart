import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/helpers/share_helper.dart';
import 'package:food_gram_app/core/utils/memory_album_utils.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/loading/app_overlay_loading.dart';
import 'package:food_gram_app/ui/component/share/memory_album/memory_album_share_poster.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 思い出アルバムのSNSシェアプレビュー＆高解像度キャプチャダイアログ
class AppMemoryAlbumShareDialog extends HookConsumerWidget {
  const AppMemoryAlbumShareDialog({
    required this.album,
    required this.posts,
    super.key,
  });

  final MemoryAlbum album;
  final List<Posts> posts;

  /// pixelRatio: 4 で 360×640 -> 1440×2560px の超高解像度PNGを生成する
  static const double _highResPixelRatio = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final loading = useState(false);
    final boundaryKey = useMemoized(GlobalKey.new);

    final imagePosts = postsWithImages(posts, max: 9);
    final imageUrls = <String>[
      for (final post in imagePosts)
        if (postImageUrl(ref, post) case final url? when url.isNotEmpty) url,
    ];

    final poster = MemoryAlbumSharePoster(
      album: album,
      posts: posts,
      imageUrls: imageUrls,
    );

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayFg = isDark ? colorScheme.onSurface : Colors.white;
    final overlayBtnBg = colorScheme.surface;
    final overlayBtnFg = colorScheme.onSurface;
    final aspectRatio =
        MemoryAlbumSharePoster.size.width / MemoryAlbumSharePoster.size.height;

    Future<void> share({required bool hasText}) async {
      if (imageUrls.isEmpty || loading.value) {
        return;
      }
      ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
        name: hasText
            ? AnalyticsEvent.postShareLink
            : AnalyticsEvent.postShareImage,
        parameters: {
          AnalyticsParam.albumId: album.id,
          AnalyticsParam.source: 'memory_album',
        },
      );
      await ShareHelpers().captureBoundaryAndShare(
        context: context,
        boundaryKey: boundaryKey,
        loading: loading,
        hasText: hasText,
        shareText: poster.shareMessage(t),
        precacheImageUrls: imageUrls,
        pixelRatio: _highResPixelRatio,
        errorMessage: t.error.message,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  centerTitle: true,
                  leading: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.close,
                      color: overlayFg,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    t.share.previewTitle,
                    style: TextStyle(
                      color: overlayFg,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: aspectRatio,
                        child: FittedBox(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: RepaintBoundary(
                              key: boundaryKey,
                              child: poster,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: overlayBtnBg,
                            foregroundColor: overlayBtnFg,
                          ),
                          onPressed: imageUrls.isEmpty
                              ? null
                              : () => share(hasText: true),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.ios_share,
                                size: 22,
                                color: overlayBtnFg,
                              ),
                              const Gap(12),
                              Text(
                                t.share.textAndImage,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: overlayBtnFg,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: overlayBtnBg,
                            foregroundColor: overlayBtnFg,
                          ),
                          onPressed: imageUrls.isEmpty
                              ? null
                              : () => share(hasText: false),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_outlined,
                                size: 22,
                                color: overlayBtnFg,
                              ),
                              const Gap(12),
                              Text(
                                t.share.imageOnly,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: overlayBtnFg,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppProcessLoading(loading: loading.value, status: 'Loading...'),
        ],
      ),
    );
  }
}
