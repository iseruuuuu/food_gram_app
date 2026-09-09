import 'package:flutter/material.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/supabase/user/providers/post_count_rank_provider.dart';
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
    required this.textColor,
    required this.mutedColor,
    super.key,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String valueText;
  final String label;
  final Color textColor;
  final Color mutedColor;

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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: mutedColor,
          ),
        ),
      ],
    );
  }
}

class ProfileRankingUnlocked extends ConsumerStatefulWidget {
  const ProfileRankingUnlocked({
    required this.userId,
    required this.textColor,
    required this.mutedColor,
    required this.rankingLabel,
    super.key,
  });

  final String userId;
  final Color textColor;
  final Color mutedColor;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asyncRank = ref.watch(postCountRankProvider(widget.userId));
    return asyncRank.when(
      data: (rank) => ProfileStat(
        icon: Icons.emoji_events_outlined,
        iconBg: isDark ? const Color(0xFFFFE082) : const Color(0xFFFFF3CD),
        iconColor: isDark ? const Color(0xFFF57F17) : Colors.amber.shade700,
        valueText: t.profile.rankingPositionFormat
            .replaceAll('{rank}', rank.toString()),
        label: widget.rankingLabel,
        textColor: widget.textColor,
        mutedColor: widget.mutedColor,
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
                  color: widget.mutedColor,
                ),
              ),
            ),
          ),
          const Gap(8),
          Text(
            t.profile.rankingHiddenPosition,
            style: TextStyle(fontSize: 20, color: widget.textColor),
          ),
          const Gap(4),
          Text(
            widget.rankingLabel,
            style: TextStyle(fontSize: 13, color: widget.mutedColor),
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
                color: isDark
                    ? const Color(0xFFFFE082)
                    : const Color(0xFFFFF3CD),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: isDark
                    ? const Color(0xFFF57F17)
                    : Colors.grey.shade600,
              ),
            ),
            const Gap(8),
            Text(
              t.profile.rankingHiddenPosition,
              style: TextStyle(fontSize: 20, color: widget.textColor),
            ),
            const Gap(4),
            Text(
              widget.rankingLabel,
              style: TextStyle(fontSize: 13, color: widget.mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}
