import 'dart:ui' show lerpDouble;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/subscribed_users_provider.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/location/prefecture_detector.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/modal_sheet/save_album_picker_sheet.dart';
import 'package:food_gram_app/ui/screen/post_detail/post_detail_view_model.dart';
import 'package:food_gram_app/ui/screen/time_line/components/timeline_post_navigation.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Apple Music / App Store Today 風の中央主役カルーセル
class TimelineRecommendSection extends HookConsumerWidget {
  const TimelineRecommendSection({
    required this.recommendedPosts,
    required this.allPosts,
    required this.refresh,
    this.categoryName,
    super.key,
  });

  final List<Posts> recommendedPosts;
  final List<Posts> allPosts;
  final VoidCallback refresh;
  final String? categoryName;

  /// 中央カードの枠（画面幅比）。左右にチラ見せを残す
  static const double viewportFraction = 0.82;

  /// カルーセル高さ（画面幅比）
  static const double heightRatio = 0.62;

  /// 中央カードのスケール
  static const double centerScale = 1;

  /// 左右カードのスケール（中央の約83%）
  static const double sideScale = 0.83;

  /// 左右カードをわずかに下げる量
  static const double sideTranslateY = 10;

  /// カード間の余白
  static const double cardGap = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final currentPage = useState(0);
    final pageController = usePageController(
      viewportFraction: viewportFraction,
    );

    useEffect(
      () {
        final maxIndex =
            recommendedPosts.isEmpty ? 0 : recommendedPosts.length - 1;
        if (currentPage.value > maxIndex) {
          currentPage.value = maxIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (pageController.hasClients) {
              pageController.jumpToPage(maxIndex);
            }
          });
        }
        return null;
      },
      [recommendedPosts.length],
    );

    if (recommendedPosts.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardHeight = screenWidth * heightRatio;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final bgColor =
        isDark ? Theme.of(context).colorScheme.surface : Colors.white;

    return ColoredBox(
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 18)),
                const Gap(6),
                Flexible(
                  child: Text(
                    t.timeline.recommendTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: cardHeight + sideTranslateY,
            child: PageView.builder(
              controller: pageController,
              clipBehavior: Clip.none,
              physics: const BouncingScrollPhysics(
                parent: PageScrollPhysics(),
              ),
              itemCount: recommendedPosts.length,
              onPageChanged: (index) => currentPage.value = index,
              itemBuilder: (context, index) {
                final post = recommendedPosts[index];
                return AnimatedBuilder(
                  animation: pageController,
                  builder: (context, _) {
                    final page = _currentPageValue(
                      pageController,
                      currentPage.value,
                    );
                    final distance = (page - index).abs().clamp(0.0, 1.0);
                    final tCurve = Curves.easeOutCubic.transform(distance);
                    final scale = lerpDouble(centerScale, sideScale, tCurve)!;
                    final translateY = lerpDouble(0, sideTranslateY, tCurve)!;
                    final focus = Curves.easeOutCubic.transform(
                      (1.0 - distance).clamp(0.0, 1.0),
                    );

                    return Center(
                      child: Transform.translate(
                        offset: Offset(0, translateY),
                        child: Transform.scale(
                          scale: scale,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: cardGap / 2,
                            ),
                            child: _TimelineFeaturedCard(
                              post: post,
                              focus: focus,
                              onTap: () => openTimelinePostDetail(
                                context: context,
                                ref: ref,
                                allPosts: allPosts,
                                post: post,
                                refresh: refresh,
                                categoryName: categoryName,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Gap(12),
          AnimatedBuilder(
            animation: pageController,
            builder: (context, _) {
              final page = _currentPageValue(
                pageController,
                currentPage.value,
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(recommendedPosts.length, (index) {
                  final selected = (1.0 - (page - index).abs()).clamp(0.0, 1.0);
                  final eased = Curves.easeOutCubic.transform(selected);
                  final width = lerpDouble(7, 18, eased)!;
                  final opacity = lerpDouble(0.22, 1, eased)!;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: width,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: onSurface.withValues(alpha: opacity),
                    ),
                  );
                }),
              );
            },
          ),
          const Gap(4),
        ],
      ),
    );
  }

  static double _currentPageValue(
    PageController controller,
    int fallbackPage,
  ) {
    if (controller.hasClients && controller.position.hasContentDimensions) {
      return controller.page ?? fallbackPage.toDouble();
    }
    return fallbackPage.toDouble();
  }
}

/// おすすめカルーセル用カード（このファイル内専用）
///
/// [focus] は 1.0=中央、0.0=サイド。
class _TimelineFeaturedCard extends HookConsumerWidget {
  const _TimelineFeaturedCard({
    required this.post,
    required this.onTap,
    this.focus = 1,
  });

  final Posts post;
  final VoidCallback onTap;
  final double focus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final supabase = ref.watch(supabaseProvider);
    final isStored = useState<bool?>(null);
    final isTogglingStore = useState(false);
    final storageKey = post.firstFoodImage;
    final imageUrl = storageKey.isEmpty
        ? ''
        : supabase.storage.from('food').getPublicUrl(storageKey);
    final tagIds = parseFoodTagIds(post.foodTag);
    final tagLabel =
        tagIds.isEmpty ? null : getLocalizedFoodName(tagIds.first, context);
    final prefecture = PrefectureDetector.detectPrefecture(post.lat, post.lng);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth =
        (MediaQuery.sizeOf(context).width * dpr).round().clamp(400, 1200);
    final isExpanded = focus > 0.55;
    final titleSize = lerpDouble(14, 20, focus.clamp(0.0, 1.0))!;
    const radius = 26.0;
    final isSubscribed = ref.watch(isSubscribedProvider(post.userId));
    final shadowBlur = lerpDouble(8, 22, focus)!;
    final shadowOffsetY = lerpDouble(3, 10, focus)!;
    final shadowAlpha = lerpDouble(
      isDark ? 0.18 : 0.06,
      isDark ? 0.4 : 0.2,
      focus,
    )!;

    useEffect(
      () {
        var cancelled = false;
        Preference().getStringList(PreferenceKey.storeList).then((list) {
          if (!cancelled) {
            isStored.value = list.contains(post.id.toString());
          }
        }).catchError((_) {
          if (!cancelled) {
            isStored.value = false;
          }
        });
        return () {
          cancelled = true;
        };
      },
      [post.id],
    );

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            if (!isSubscribed)
              BoxShadow(
                color: Colors.black.withValues(alpha: shadowAlpha),
                blurRadius: shadowBlur,
                offset: Offset(0, shadowOffsetY),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Card(
                  elevation: 0,
                  margin: isSubscribed
                      ? const EdgeInsets.all(5)
                      : EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      isSubscribed ? 0 : radius,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (storageKey.isEmpty)
                        ColoredBox(
                          color: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade200,
                        )
                      else
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: cacheWidth,
                          placeholder: (context, url) => ColoredBox(
                            color: isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            isDark
                                ? Assets.image.emptyDark.path
                                : Assets.image.empty.path,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Color(0x66000000),
                              Color(0xCC000000),
                            ],
                            stops: [0.0, 0.42, 0.72, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSubscribed)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: IgnorePointer(
                      child: Image.asset(
                        Assets.image.frame.path,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              if (tagLabel != null)
                Positioned(
                  top: isSubscribed ? 18 : 14,
                  left: isSubscribed ? 16 : 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tagLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isExpanded ? 12 : 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: isSubscribed ? 14 : 10,
                right: isSubscribed ? 14 : 10,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    if (isStored.value == null || isTogglingStore.value) {
                      return;
                    }
                    final previous = isStored.value!;
                    isTogglingStore.value = true;
                    try {
                      await ref
                          .read(postDetailViewModelProvider().notifier)
                          .store(
                        postId: post.id,
                        openSnackBar: () {
                          if (!context.mounted) {
                            return;
                          }
                          SnackBarHelper().openSavedPostWithAlbumAction(
                            context,
                            title: t.stored.postSaved,
                            subtitle: t.stored.postSavedMessage,
                            addToAlbumLabel: t.stored.albumAddTo,
                            onAddToAlbum: () {
                              if (!context.mounted) {
                                return;
                              }
                              showSaveAlbumPickerSheet(
                                context: context,
                                ref: ref,
                                postId: post.id,
                              );
                            },
                          );
                        },
                      );
                      if (!context.mounted) {
                        return;
                      }
                      final list = await Preference()
                          .getStringList(PreferenceKey.storeList);
                      if (!context.mounted) {
                        return;
                      }
                      isStored.value = list.contains(post.id.toString());
                    } catch (_) {
                      if (context.mounted) {
                        isStored.value = previous;
                      }
                    } finally {
                      if (context.mounted) {
                        isTogglingStore.value = false;
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      (isStored.value ?? false)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: Colors.white.withValues(
                        alpha: isStored.value == null || isTogglingStore.value
                            ? 0.45
                            : 1,
                      ),
                      size: isExpanded ? 22 : 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: isSubscribed ? 16 : 12,
                right: isSubscribed ? 16 : 12,
                bottom: isSubscribed ? 18 : 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            post.foodName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          if (isExpanded && post.restaurant.isNotEmpty) ...[
                            const Gap(4),
                            Text(
                              post.restaurant,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          if (prefecture != null) ...[
                            const Gap(6),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: isExpanded ? 14 : 12,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                const Gap(2),
                                Expanded(
                                  child: Text(
                                    prefecture,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      fontSize: isExpanded ? 12 : 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isExpanded) ...[
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.heart_fill,
                              size: 14,
                              color: Colors.redAccent,
                            ),
                            const Gap(4),
                            Text(
                              '${post.heart}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
