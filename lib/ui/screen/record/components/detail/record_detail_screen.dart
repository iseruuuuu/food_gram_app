import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_food_traits_section.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_recent_section.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_stat_section.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_summary_section.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_yearly_section.dart';
import 'package:food_gram_app/ui/screen/record/components/record_tab.dart';
import 'package:food_gram_app/ui/screen/record/record_view_model.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 記録タブの全体のUI
class RecordDetailScreen extends ConsumerWidget {
  const RecordDetailScreen({required this.posts, super.key});

  final List<Posts> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordViewModelProvider);
    final isSubscribe = ref.watch(isSubscribeProvider).valueOrNull ?? false;
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161616) : Colors.white;
    final mutedColor = isDark ? Colors.white70 : Colors.black54;
    final recentPosts = [...posts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latest3 = recentPosts.take(3).toList();
    final yearlyCounts = <int, int>{};
    for (final post in posts) {
      final year = post.createdAt.year;
      yearlyCounts[year] = (yearlyCounts[year] ?? 0) + 1;
    }
    final sortedYears = yearlyCounts.keys.toList()..sort();
    final activityDays = recordActivityDaysSpan(posts);
    final selectorTop = recordMapOverlayTopForContext(context);
    const viewTypeTabHeight = 68.0;
    return Stack(
      children: [
        SingleChildScrollView(
          padding:
              EdgeInsets.fromLTRB(16, selectorTop + viewTypeTabHeight, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecordSummarySection(
                activityDays: activityDays,
                cardColor: cardColor,
                mutedColor: mutedColor,
              ),
              const Gap(12),
              Row(
                children: [
                  RecordStatSection(
                    emoji: '📍',
                    value: '${state.visitedAreasCount}',
                    label: t.mapStats.visitedArea,
                    valueColor: const Color(0xFF2563EB),
                  ),
                  const Gap(8),
                  RecordStatSection(
                    emoji: '🍜',
                    value: '${posts.length}',
                    label: t.myMapRecord.postedMealsLabel,
                    valueColor: const Color(0xFFEA4335),
                  ),
                  const Gap(8),
                  RecordStatSection(
                    emoji: '📅',
                    value: '$activityDays',
                    label: t.mapStats.activityDays,
                    valueColor: const Color(0xFF16A34A),
                  ),
                ],
              ),
              const Gap(16),
              RecordFoodTraitsSection(
                posts: posts,
                cardColor: cardColor,
                mutedColor: mutedColor,
                isSubscribed: isSubscribe,
                onTapPremiumCta: () {
                  ref
                      .read(revenueCatServiceProvider.notifier)
                      .presentPaywallGuarded();
                },
              ),
              const Gap(16),
              RecordYearlySection(
                cardColor: cardColor,
                mutedColor: mutedColor,
                sortedYears: sortedYears,
                yearlyCounts: yearlyCounts,
                recentPosts: recentPosts,
              ),
              const Gap(16),
              RecordRecentSection(
                cardColor: cardColor,
                mutedColor: mutedColor,
                latestPosts: latest3,
              ),
            ],
          ),
        ),
        Positioned(
          top: selectorTop,
          left: 0,
          right: 0,
          child: RecordTab(
            currentViewType: MapViewType.detail,
            onViewTypeChanged:
                ref.read(recordViewModelProvider.notifier).changeViewType,
          ),
        ),
      ],
    );
  }
}

double recordMapOverlayTopForContext(BuildContext context) {
  final topInset = MediaQuery.of(context).padding.top;
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth <= 375) {
    return topInset + 8;
  } else if (screenWidth < 720) {
    return topInset + 16;
  } else {
    return topInset + 12;
  }
}
