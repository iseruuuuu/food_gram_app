import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/helpers/share_helper.dart';
import 'package:food_gram_app/core/utils/memory_album_utils.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/loading/app_overlay_loading.dart';
import 'package:food_gram_app/ui/component/share/memory_album/memory_album_share_poster.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 思い出アルバムのSNSシェアプレビュー＆高解像度キャプチャダイアログ。
///
/// 1ページ目に「1〜9枚まとめポスター（表紙）」を表示し、
/// 投稿が複数ある場合は2ページ目以降に「各料理の個別カード」を横スワイプで表示。
/// 「表紙のみ（1枚）」でも「表紙＋個別カードの複数枚セット」でも一括高画質出力できる。
class AppMemoryAlbumShareDialog extends HookConsumerWidget {
  const AppMemoryAlbumShareDialog({
    required this.album,
    required this.posts,
    super.key,
  });

  final MemoryAlbum album;
  final List<Posts> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final loading = useState(false);
    final currentPage = useState(0);
    final includeDetailCards = useState(posts.length > 1);
    final pageController = usePageController(viewportFraction: 0.88);

    final imagePosts = postsWithImages(posts, max: 9);
    final imageUrls = <String>[
      for (final post in imagePosts)
        if (postImageUrl(ref, post) case final url? when url.isNotEmpty) url,
    ];

    // 2枚ずつペアにしてスライド化（例: 6枚なら3スライド、5枚なら3スライド）
    final pairedUrlChunks = <List<String>>[
      for (var i = 0; i < imageUrls.length; i += 2)
        imageUrls.sublist(
          i,
          (i + 2) > imageUrls.length ? imageUrls.length : (i + 2),
        ),
    ];

    final hasMultipleSlides = imageUrls.length > 1;
    final totalSlideCount =
        hasMultipleSlides && includeDetailCards.value
            ? 1 + pairedUrlChunks.length
            : 1;

    final boundaryKeys = useMemoized(
      () => List.generate(1 + pairedUrlChunks.length, (_) => GlobalKey()),
      [pairedUrlChunks.length],
    );

    final coverPoster = MemoryAlbumSharePoster(
      album: album,
      posts: posts,
      imageUrls: imageUrls,
    );

    final slideWidgets = <Widget>[
      coverPoster,
      for (var i = 0; i < pairedUrlChunks.length; i++)
        MemoryAlbumShareSlideCard(
          albumTitle: album.title,
          imageUrls: pairedUrlChunks[i],
          slideIndex: i + 1,
          totalSlides: pairedUrlChunks.length,
        ),
    ];

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayFg = isDark ? colorScheme.onSurface : Colors.white;
    final overlayBtnBg = colorScheme.surface;
    final overlayBtnFg = colorScheme.onSurface;
    final aspectRatio =
        MemoryAlbumSharePoster.size.width / MemoryAlbumSharePoster.size.height;

    final isJa = Localizations.localeOf(context).languageCode == 'ja';
    final coverOnlyLabel = isJa ? '1枚にまとめる' : '1 Image';
    final multiSetLabel = isJa
        ? '複数枚 (${1 + pairedUrlChunks.length}枚)'
        : 'All (${1 + pairedUrlChunks.length})';

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
          AnalyticsParam.source:
              includeDetailCards.value && hasMultipleSlides
                  ? 'memory_album_carousel'
                  : 'memory_album_cover',
        },
      );
      final activeKeys = boundaryKeys.sublist(0, totalSlideCount);
      await ShareHelpers().captureMultipleBoundariesAndShare(
        context: context,
        boundaryKeys: activeKeys,
        loading: loading,
        hasText: hasText,
        shareText: coverPoster.shareMessage(t),
        precacheImageUrls: imageUrls,
        errorMessage: t.error.message,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.92),
      body: Stack(
        children: [
          // 画面外で全スライドのRepaintBoundaryを常時マウントしておく（どのページにいても全枚数を一括キャプチャ可能にする）
          Positioned(
            left: -4000,
            top: 0,
            child: IgnorePointer(
              child: Column(
                children: [
                  for (var i = 0; i < slideWidgets.length; i++)
                    RepaintBoundary(
                      key: boundaryKeys[i],
                      child: slideWidgets[i],
                    ),
                ],
              ),
            ),
          ),
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
                if (hasMultipleSlides)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment<bool>(
                          value: false,
                          icon: const Icon(Icons.crop_portrait, size: 16),
                          label: Text(
                            coverOnlyLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ButtonSegment<bool>(
                          value: true,
                          icon: const Icon(
                            Icons.collections_outlined,
                            size: 16,
                          ),
                          label: Text(
                            multiSetLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      selected: {includeDetailCards.value},
                      onSelectionChanged: (selected) {
                        final next = selected.first;
                        includeDetailCards.value = next;
                        if (!next && currentPage.value != 0) {
                          currentPage.value = 0;
                          if (pageController.hasClients) {
                            pageController.jumpToPage(0);
                          }
                        }
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          return states.contains(WidgetState.selected)
                              ? AppTheme.primaryOrange
                              : Colors.white12;
                        }),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                      ),
                    ),
                  ),
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: totalSlideCount,
                    onPageChanged: (idx) => currentPage.value = idx,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: aspectRatio,
                            child: FittedBox(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: slideWidgets[index],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (totalSlideCount > 1) ...[
                  const Gap(6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(totalSlideCount, (idx) {
                      final active = currentPage.value == idx;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? AppTheme.primaryOrange
                              : Colors.white38,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: imageUrls.isEmpty
                              ? null
                              : () => share(hasText: true),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.ios_share,
                                size: 22,
                                color: Colors.white,
                              ),
                              const Gap(12),
                              Text(
                                t.share.textAndImage,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(10),
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
                                Icons.photo_library_outlined,
                                size: 22,
                                color: overlayBtnFg,
                              ),
                              const Gap(12),
                              Text(
                                t.share.imageOnly,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: overlayBtnFg,
                                  fontWeight: FontWeight.w600,
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
