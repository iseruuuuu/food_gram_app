import 'package:flutter/material.dart';
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
        const Gap(4),
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

class ProfileRankingLocked extends StatelessWidget {
  const ProfileRankingLocked({
    required this.textColor,
    required this.mutedColor,
    required this.rankingLabel,
    required this.memberOnlyLabel,
    required this.isDark,
    required this.onTap,
    super.key,
  });

  final Color textColor;
  final Color mutedColor;
  final String rankingLabel;
  final String memberOnlyLabel;
  final bool isDark;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    const radius = 12.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                if (isDark) ...[
                  Colors.orange.shade50.withValues(alpha: 0.25),
                  Colors.grey.shade900,
                ] else ...[
                  Colors.orange.shade50,
                  Colors.grey.shade100,
                ],
              ],
            ),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 22,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const Gap(6),
              Text(
                Translations.of(context).profile.rankingHiddenPosition,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Gap(4),
              Text(
                rankingLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: mutedColor,
                ),
              ),
              const Gap(8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  memberOnlyLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileRankingUnlocked extends StatelessWidget {
  const ProfileRankingUnlocked({
    required this.userId,
    required this.textColor,
    required this.mutedColor,
    required this.rankingLabel,
    required this.ref,
    super.key,
  });

  final String userId;
  final Color textColor;
  final Color mutedColor;
  final String rankingLabel;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final asyncRank = ref.watch(postCountRankProvider(userId));
    return asyncRank.when(
      data: (rank) => ProfileStat(
        icon: Icons.emoji_events_outlined,
        iconBg: const Color(0xFFE8EAF6),
        iconColor: Colors.indigo.shade400,
        valueText: t.profile.rankingPositionFormat
            .replaceAll('{rank}', rank.toString()),
        label: rankingLabel,
        textColor: textColor,
        mutedColor: mutedColor,
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
                  color: mutedColor,
                ),
              ),
            ),
          ),
          const Gap(8),
          Text('—', style: TextStyle(fontSize: 20, color: textColor)),
          const Gap(4),
          Text(
            rankingLabel,
            style: TextStyle(fontSize: 13, color: mutedColor),
          ),
        ],
      ),
      error: (_, __) => Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE8EAF6),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, color: Colors.grey.shade600),
          ),
          const Gap(8),
          Text('—', style: TextStyle(fontSize: 20, color: textColor)),
          const Gap(4),
          Text(
            rankingLabel,
            style: TextStyle(fontSize: 13, color: mutedColor),
          ),
        ],
      ),
    );
  }
}
