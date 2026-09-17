import 'package:flutter/material.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/supabase/user/providers/post_count_rank_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/theme/style/profile_style.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileStat extends StatelessWidget {
  const ProfileStat({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.valueText,
    required this.label,
    super.key,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String valueText;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const Gap(8),
        Text(
          valueText,
          style: ProfileStyle.statValue(context),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: ProfileStyle.statLabel(context),
        ),
      ],
    );
  }
}

class ProfileRankingUnlocked extends ConsumerStatefulWidget {
  const ProfileRankingUnlocked({
    required this.userId,
    required this.rankingLabel,
    super.key,
  });

  final String userId;
  final String rankingLabel;

  @override
  ConsumerState<ProfileRankingUnlocked> createState() =>
      _ProfileRankingUnlockedState();
}

class _ProfileRankingUnlockedState
    extends ConsumerState<ProfileRankingUnlocked> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      // Profile 上のウィジェットなので logScreen(Ranking) は送らない
      // （送ると以降のイベントが Ranking 画面に紐づく）
      ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
            name: AnalyticsEvent.rankingOpen,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final iconBg = AppTheme.orangeBackgroundOf(context);
    const iconColor = AppTheme.primaryOrange;
    final asyncRank = ref.watch(postCountRankProvider(widget.userId));
    return asyncRank.when(
      data: (rank) => ProfileStat(
        icon: Icons.emoji_events_outlined,
        iconBg: iconBg,
        iconColor: iconColor,
        valueText: t.profile.rankingPositionFormat
            .replaceAll('{rank}', rank.toString()),
        label: widget.rankingLabel,
      ),
      loading: () => Column(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.textSecondaryOf(context),
                ),
              ),
            ),
          ),
          const Gap(8),
          Text(
            t.profile.rankingHiddenPosition,
            style: ProfileStyle.statValue(context),
          ),
          const Gap(4),
          Text(
            widget.rankingLabel,
            style: ProfileStyle.statLabel(context),
          ),
        ],
      ),
      error: (_, __) => GestureDetector(
        onTap: () => ref.invalidate(postCountRankProvider(widget.userId)),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: AppTheme.textSecondaryOf(context),
              ),
            ),
            const Gap(8),
            Text(
              t.profile.rankingHiddenPosition,
              style: ProfileStyle.statValue(context),
            ),
            const Gap(4),
            Text(
              widget.rankingLabel,
              style: ProfileStyle.statLabel(context),
            ),
          ],
        ),
      ),
    );
  }
}
