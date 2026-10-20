import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/theme/style/restaurant_review_style.dart';
import 'package:food_gram_app/core/utils/restaurant/restaurant_display_name.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:food_gram_app/ui/component/app_translatable_text.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/loading/app_skeleton.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:photo_viewer/photo_viewer.dart';

class RestaurantReviewScreen extends HookConsumerWidget {
  const RestaurantReviewScreen({
    required this.posts,
    super.key,
  });

  final Posts posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        final analytics = ref.read(firebaseAnalyticsServiceProvider);
        analytics.logEventUnawaited(name: AnalyticsEvent.restaurantDetailOpen);
        analytics.logEventUnawaited(name: AnalyticsEvent.restaurantReviewOpen);
        return null;
      },
      const [],
    );
    final reviewsAsync = ref.watch(
      restaurantReviewsProvider(
        lat: posts.lat,
        lng: posts.lng,
      ),
    );
    final t = Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final deviceWidth = MediaQuery.of(context).size.width;
    String getImageUrl(String imagePath) {
      return ref
          .watch(supabaseProvider)
          .storage
          .from('food')
          .getPublicUrl(imagePath);
    }

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: context.pop,
          child: const Icon(Icons.close, size: 30),
        ),
        title: FittedBox(
          child: AppTranslatableText(
            posts.restaurant,
            style: RestaurantReviewStyle.restaurant(colorScheme.onSurface),
          ),
        ),
      ),
      body: AsyncValueSwitcher(
        asyncValue: reviewsAsync,
        onLoading: const AppPostDetailSkeleton(),
        onErrorTap: () async => ref.refresh(
          restaurantReviewsProvider(
            lat: posts.lat,
            lng: posts.lng,
          ),
        ),
        onData: (reviews) => RefreshIndicator(
          onRefresh: () async => ref.refresh(
            restaurantReviewsProvider(
              lat: posts.lat,
              lng: posts.lng,
            ),
          ),
          child: reviews.when(
            success: (data) {
              if (data.isEmpty) {
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: const [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmpty(),
                    ),
                  ],
                );
              }
              final sorted = [...data]..sort(
                  (a, b) => b.posts.createdAt.compareTo(a.posts.createdAt),
                );
              void openPostDetail(Model model) {
                ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
                  name: AnalyticsEvent.restaurantReviewPostOpen,
                  parameters: {
                    AnalyticsParam.postId: model.posts.id,
                  },
                );
                context.pushNamed(
                  RouterPath.searchDetailPost,
                  extra: model,
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                itemCount: sorted.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _RestaurantHeroHeader(
                      model: sorted.first,
                      getImageUrl: getImageUrl,
                      onTapDetail: () => openPostDetail(sorted.first),
                    );
                  }
                  if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const Gap(8),
                          Text(
                            t.restaurantReview.reviewList,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final model = sorted[index - 2];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: _RestaurantSpeechBubbleItem(
                      model: model,
                      deviceWidth: deviceWidth,
                      getImageUrl: getImageUrl,
                      onTapDetail: () => openPostDetail(model),
                    ),
                  );
                },
              );
            },
            failure: (_) {
              return Center(
                child: Text(
                  t.restaurantReview.error,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RestaurantHeroHeader extends StatelessWidget {
  const _RestaurantHeroHeader({
    required this.model,
    required this.getImageUrl,
    required this.onTapDetail,
  });

  final Model model;
  final String Function(String imagePath) getImageUrl;
  final VoidCallback onTapDetail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final firstImage = model.posts.firstFoodImage;

    return GestureDetector(
      onTap: onTapDetail,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: firstImage.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: getImageUrl(firstImage),
                fit: BoxFit.cover,
                placeholder: (context, url) => ColoredBox(
                  color: colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            : ColoredBox(color: colorScheme.surfaceContainerHighest),
      ),
    );
  }
}

class _RestaurantSpeechBubbleItem extends StatelessWidget {
  const _RestaurantSpeechBubbleItem({
    required this.model,
    required this.deviceWidth,
    required this.getImageUrl,
    required this.onTapDetail,
  });

  final Model model;
  final double deviceWidth;
  final String Function(String imagePath) getImageUrl;
  final VoidCallback onTapDetail;

  static const double _avatarSize = 38;
  static const double _avatarGap = 10;
  static const double _bubbleIndent = _avatarSize + _avatarGap;
  static const double _tailHeight = 7;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final post = model.posts;
    final user = model.users;

    final bubbleBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bubbleBorder =
        isDark ? colorScheme.outlineVariant : const Color(0xFFE0DDD6);
    final mutedColor = isDark ? Colors.white60 : const Color(0xFF8C867E);
    final linkColor =
        isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0);

    final price = post.formattedPriceDisplay;
    final titleText = post.localizedDisplayTitle(t);
    final comment = post.comment.trim();
    final firstImage = post.firstFoodImage;
    final visitDate = DateFormat('yyyy/MM').format(post.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppProfileImage(
              imagePath: user.image,
              radius: _avatarSize / 2,
            ),
            const Gap(_avatarGap),
            Expanded(
              child: Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const Gap(4),
        Padding(
          padding: const EdgeInsets.only(left: _bubbleIndent),
          child: GestureDetector(
            onTap: onTapDetail,
            behavior: HitTestBehavior.opaque,
            child: CustomPaint(
              painter: _SpeechBubblePainter(
                fillColor: bubbleBg,
                borderColor: bubbleBorder,
                tailHeight: _tailHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  _tailHeight + 12,
                  14,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomPaint(
                      painter: _DottedUnderlinePainter(
                        color:
                            isDark ? Colors.white38 : const Color(0xFF9E9990),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          titleText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (comment.isNotEmpty) ...[
                                Text(
                                  comment,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.88,
                                    ),
                                  ),
                                ),
                                const Gap(4),
                              ],
                              Text(
                                t.restaurantReview.viewDetails,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: linkColor,
                                ),
                              ),
                              if (price.isNotEmpty) ...[
                                const Gap(6),
                                Text(
                                  price,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (firstImage.isNotEmpty) ...[
                          const Gap(12),
                          GestureDetector(
                            onTap: () {
                              showPhotoViewer(
                                context: context,
                                heroTagBuilder: (context) =>
                                    'review-image-${post.id}',
                                builder: (context) => Container(
                                  width: deviceWidth,
                                  height: deviceWidth,
                                  color: colorScheme.surface,
                                  child: CachedNetworkImage(
                                    imageUrl: getImageUrl(firstImage),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 68,
                              height: 68,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                                      imageUrl: getImageUrl(firstImage),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => ColoredBox(
                                        color:
                                            colorScheme.surfaceContainerHighest,
                                      ),
                                    ),
                                  ),
                                  if (post.foodImageList.length > 1)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.collections,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Gap(12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              size: 16,
                              color: Colors.pinkAccent,
                            ),
                            const Gap(4),
                            Text(
                              '${post.heart}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                        if (post.star > 0)
                          _StarRow(
                            star: post.star,
                            isDark: isDark,
                          ),
                        Text(
                          visitDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({
    required this.star,
    required this.isDark,
  });

  final double star;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFF59E0B);
    final inactiveColor = isDark ? Colors.white24 : const Color(0xFFD9D6CE);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final IconData icon;
        final Color color;
        if (star >= starNumber) {
          icon = Icons.star_rounded;
          color = activeColor;
        } else if (star >= starNumber - 0.5) {
          icon = Icons.star_half_rounded;
          color = activeColor;
        } else {
          icon = Icons.star_rounded;
          color = inactiveColor;
        }
        return Icon(
          icon,
          size: 16,
          color: color,
        );
      }),
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  const _SpeechBubblePainter({
    required this.fillColor,
    required this.borderColor,
    required this.tailHeight,
  });

  final Color fillColor;
  final Color borderColor;
  final double tailHeight;

  @override
  void paint(Canvas canvas, Size size) {
    const radius = 8.0;
    const tailLeft = 18.0;
    const tailWidth = 12.0;
    final top = tailHeight;

    final path = Path()
      ..moveTo(radius, top)
      ..lineTo(tailLeft, top)
      ..lineTo(tailLeft + tailWidth / 2, 0)
      ..lineTo(tailLeft + tailWidth, top)
      ..lineTo(size.width - radius, top)
      ..arcToPoint(
        Offset(size.width, top + radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(size.width, size.height - radius)
      ..arcToPoint(
        Offset(size.width - radius, size.height),
        radius: const Radius.circular(radius),
      )
      ..lineTo(radius, size.height)
      ..arcToPoint(
        Offset(0, size.height - radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(0, top + radius)
      ..arcToPoint(
        Offset(radius, top),
        radius: const Radius.circular(radius),
      )
      ..close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas
      ..drawPath(path, fillPaint)
      ..drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SpeechBubblePainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.tailHeight != tailHeight;
  }
}

class _DottedUnderlinePainter extends CustomPainter {
  const _DottedUnderlinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 2.0;
    const dashSpace = 2.5;
    var startX = 0.0;
    final y = size.height;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset((startX + dashWidth).clamp(0.0, size.width), y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedUnderlinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
