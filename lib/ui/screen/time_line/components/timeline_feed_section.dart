import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_rectangle_banner.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/subscribed_users_provider.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/screen/time_line/components/timeline_post_navigation.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 「みんなの投稿」2列グリッド（Sliver）
class TimelineFeedSection extends HookConsumerWidget {
  const TimelineFeedSection({
    required this.feedPosts,
    required this.allPosts,
    required this.refresh,
    this.categoryName,
    super.key,
  });

  final List<Posts> feedPosts;
  final List<Posts> allPosts;
  final VoidCallback refresh;
  final String? categoryName;
  static const int _adEvery = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final impressedPostIds = useRef<Set<int>>({});
    final onSurface = Theme.of(context).colorScheme.onSurface;
    if (feedPosts.isEmpty) {
      return const SliverToBoxAdapter(child: AppEmpty());
    }
    final rowCount = (feedPosts.length / 2).ceil();
    final adRowInterval = (_adEvery / 2).floor().clamp(1, _adEvery);
    final itemCount = rowCount + (rowCount ~/ adRowInterval);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  // const Text('🌱', style: TextStyle(fontSize: 18)),
                  // const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      t.timeline.everyonePosts,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final rowIndex = index - 1;
          final isAdRow = (rowIndex + 1) % (adRowInterval + 1) == 0;
          if (isAdRow) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: RectangleBanner(id: 'feed_row_$rowIndex'),
              ),
            );
          }

          final actualRowIndex = rowIndex - (rowIndex ~/ (adRowInterval + 1));
          final startIndex = actualRowIndex * 2;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(2, (col) {
                final itemIndex = startIndex + col;
                if (itemIndex >= feedPosts.length) {
                  return const Expanded(child: SizedBox.shrink());
                }
                final post = feedPosts[itemIndex];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: col == 0 ? 0 : 5,
                      right: col == 1 ? 0 : 5,
                    ),
                    child: _VisibleImpression(
                      postId: post.id,
                      loggedIds: impressedPostIds.value,
                      onVisible: (postId) {
                        ref
                            .read(firebaseAnalyticsServiceProvider)
                            .logEventUnawaited(
                          name: AnalyticsEvent.timelinePostImpression,
                          parameters: {AnalyticsParam.postId: postId},
                        );
                      },
                      child: _TimelineFeedCard(
                        post: post,
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
                );
              }),
            ),
          );
        },
        childCount: itemCount + 1,
      ),
    );
  }
}

/// グリッド用の小カード（このファイル内専用）
class _TimelineFeedCard extends ConsumerWidget {
  const _TimelineFeedCard({
    required this.post,
    required this.onTap,
  });

  final Posts post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final supabase = ref.watch(supabaseProvider);
    final isSubscribed = ref.watch(isSubscribedProvider(post.userId));
    final storageKey = post.firstFoodImage;
    final imageUrl = storageKey.isEmpty
        ? ''
        : supabase.storage.from('food').getPublicUrl(storageKey);
    final hasMultipleImages = post.foodImageList.length > 1;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cacheWidth = ((MediaQuery.sizeOf(context).width / 2) *
            MediaQuery.devicePixelRatioOf(context))
        .round()
        .clamp(200, 800);
    const radius = 16.0;

    final image = storageKey.isEmpty
        ? ColoredBox(
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            memCacheWidth: cacheWidth,
            placeholder: (context, url) => ColoredBox(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
            ),
            errorWidget: (context, url, error) => Image.asset(
              isDark ? Assets.image.emptyDark.path : Assets.image.empty.path,
              fit: BoxFit.cover,
            ),
          );

    final textRow = Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 12),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 14,
            color: onSurface.withValues(alpha: 0.45),
          ),
          const Gap(4),
          Expanded(
            child: Text(
              post.restaurant.isNotEmpty ? post.restaurant : post.foodName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: onSurface.withValues(alpha: 0.35),
          ),
        ],
      ),
    );

    final cardBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 3 / 2,
          child: image,
        ),
        textRow,
      ],
    );

    final multiImageBadge = hasMultipleImages
        ? Positioned(
            top: isSubscribed ? 10 : 8,
            right: isSubscribed ? 10 : 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.collections,
                color: Colors.white,
                size: 14,
              ),
            ),
          )
        : null;

    // サブスク: 画像＋文字を1つの四角にし、外周に金色枠
    if (isSubscribed) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              Card(
                elevation: 0,
                margin: const EdgeInsets.all(4),
                color: surface,
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: cardBody,
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Image.asset(
                    Assets.image.frame.path,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              if (multiImageBadge != null) multiImageBadge,
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              cardBody,
              if (multiImageBadge != null) multiImageBadge,
            ],
          ),
        ),
      ),
    );
  }
}

/// 実表示時のみインプレッションを記録する（キャッシュ領域の build では発火しない）
class _VisibleImpression extends StatefulWidget {
  const _VisibleImpression({
    required this.postId,
    required this.loggedIds,
    required this.onVisible,
    required this.child,
  });

  final int postId;
  final Set<int> loggedIds;
  final ValueChanged<int> onVisible;
  final Widget child;

  @override
  State<_VisibleImpression> createState() => _VisibleImpressionState();
}

class _VisibleImpressionState extends State<_VisibleImpression> {
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (!identical(_position, position)) {
      _position?.removeListener(_checkVisibility);
      _position = position;
      _position?.addListener(_checkVisibility);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    _position?.removeListener(_checkVisibility);
    super.dispose();
  }

  void _checkVisibility() {
    if (!mounted) {
      return;
    }
    if (widget.loggedIds.contains(widget.postId)) {
      return;
    }
    if (!_isVisibleEnough()) {
      return;
    }
    if (!widget.loggedIds.add(widget.postId)) {
      return;
    }
    widget.onVisible(widget.postId);
  }

  bool _isVisibleEnough({double minFraction = 0.4}) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) {
      return false;
    }
    final itemRect = box.localToGlobal(Offset.zero) & box.size;
    final media = MediaQuery.of(context);
    final viewRect = Rect.fromLTWH(
      0,
      media.padding.top,
      media.size.width,
      media.size.height - media.padding.top - media.padding.bottom,
    );
    final visible = itemRect.intersect(viewRect);
    if (visible.isEmpty || itemRect.height <= 0) {
      return false;
    }
    return visible.height / itemRect.height >= minFraction;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
