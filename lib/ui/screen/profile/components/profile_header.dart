import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/analytics_screen.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/utils/user_level.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:food_gram_app/ui/component/dialog/app_profile_dialog.dart';
import 'package:food_gram_app/ui/screen/memory_album/components/memory_album_entry_card.dart';
import 'package:food_gram_app/ui/screen/profile/components/profile_stat.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/my_profile_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class AppProfileHeader extends ConsumerWidget {
  const AppProfileHeader({
    required this.users,
    required this.length,
    required this.heartAmount,
    this.rankingUnlockedOverride,
    super.key,
  });

  final Users users;
  final int length;
  final int heartAmount;
  final bool? rankingUnlockedOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final isViewerSubscribed =
        ref.watch(isSubscribeProvider).valueOrNull ?? false;
    final rankingUnlocked = rankingUnlockedOverride ??
        users.isSubscribe || (currentUser != null && isViewerSubscribed);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = Theme.of(context).colorScheme.surface;
    final textColor = isDark ? Colors.white : Colors.black;
    final textColor87 = isDark ? Colors.white70 : Colors.black87;
    const avatarRadius = 60.0;
    final level = UserLevel.levelFromPostCount(length);
    final isOwnProfile = currentUser == users.userId;

    return ColoredBox(
      color: headerBg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final isDefaultIcon =
                        AppProfileImage.isDefaultIcon(users.image);
                    final isSubscribed = users.isSubscribe || isViewerSubscribed;
                    if (isOwnProfile && isDefaultIcon && !isSubscribed) {
                      await ref
                          .read(revenueCatServiceProvider.notifier)
                          .presentPaywallGuarded();
                      return;
                    }
                    if (!context.mounted) {
                      return;
                    }
                    await showDialog<void>(
                      context: context,
                      builder: (_) {
                        return AppProfileDialog(image: users.image);
                      },
                    );
                  },
                  child: AppProfileImage(
                    imagePath: users.image,
                    radius: avatarRadius,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              users.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (users.isSubscribe) ...[
                            const Gap(6),
                            Assets.image.profileIcon.image(
                              width: 26,
                              height: 26,
                            ),
                          ],
                        ],
                      ),
                      const Gap(2),
                      Text(
                        '@${users.userName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (rankingUnlocked) ...[
                        const Gap(8),
                        _RankBadge(
                          rankLabel: _getRank(context, length),
                          trophyAsset: _getTrophyAsset(length),
                          isDark: isDark,
                          rankSuffix: t.rank.label,
                          levelLabel: level >= UserLevel.maxLevel
                              ? t.profile.levelMax
                              : t.profile.levelLabel.replaceAll(
                                  '{level}',
                                  level.toString(),
                                ),
                        ),
                      ] else if (isOwnProfile) ...[
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            level >= UserLevel.maxLevel
                                ? t.profile.levelMax
                                : t.profile.levelLabel.replaceAll(
                                    '{level}',
                                    level.toString(),
                                  ),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? Colors.white : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (users.selfIntroduce.isNotEmpty) ...[
              const Gap(14),
              Text(
                users.selfIntroduce,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ],
            if (isOwnProfile && level < UserLevel.maxLevel) ...[
              const Gap(12),
              Builder(
                builder: (context) {
                  final parts = t.profile.nextLevelBanner.split('{count}');
                  final count = UserLevel.postsNeededForNextLevel(length) ?? 0;
                  final nextLevelColor =
                      isDark ? Colors.white70 : Colors.black54;
                  if (parts.length != 2) {
                    return Text(
                      t.profile.nextLevelBanner.replaceAll(
                        '{count}',
                        count.toString(),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: nextLevelColor,
                      ),
                    );
                  }
                  return RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        color: nextLevelColor,
                      ),
                      children: [
                        TextSpan(text: parts[0]),
                        TextSpan(
                          text: count.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.orange.shade200
                                : Colors.orange.shade800,
                          ),
                        ),
                        TextSpan(text: parts[1]),
                      ],
                    ),
                  );
                },
              ),
              const Gap(8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: UserLevel.progressToNextLevel(length),
                  minHeight: 6,
                  backgroundColor:
                      isDark ? Colors.white12 : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.grey.shade500 : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
            const Gap(20),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ProfileStat(
                      icon: Icons.restaurant_rounded,
                      iconBg: const Color(0xFFFFF3CD),
                      iconColor:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      valueText: length.toString(),
                      label: t.profile.postCount,
                      textColor: textColor,
                      mutedColor: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  VerticalDivider(
                    width: 17,
                    thickness: 1,
                    indent: 6,
                    endIndent: 6,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  Expanded(
                    child: ProfileStat(
                      icon: Icons.favorite_rounded,
                      iconBg: const Color(0xFFFFE4EC),
                      iconColor: Colors.red.shade400,
                      valueText: heartAmount.toString(),
                      label: t.likeButton,
                      textColor: textColor,
                      mutedColor: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  VerticalDivider(
                    width: 17,
                    thickness: 1,
                    indent: 6,
                    endIndent: 6,
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  Expanded(
                    child: rankingUnlocked
                        ? ProfileRankingUnlocked(
                            userId: users.userId,
                            textColor: textColor,
                            mutedColor:
                                isDark ? Colors.white70 : Colors.black54,
                            rankingLabel: t.profile.rankingStats,
                          )
                        : ProfileRankingLocked(
                            textColor: textColor,
                            mutedColor:
                                isDark ? Colors.white70 : Colors.black54,
                            rankingLabel: t.profile.rankingStats,
                            memberOnlyLabel: t.profile.memberOnlyBadge,
                            isDark: isDark,
                            onTap: () async {
                              final analytics =
                                  ref.read(firebaseAnalyticsServiceProvider);
                              analytics.logScreen(AnalyticsScreen.ranking);
                              analytics.logEventUnawaited(
                                name: AnalyticsEvent.rankingOpen,
                              );
                              try {
                                await ref
                                    .read(
                                      revenueCatServiceProvider.notifier,
                                    )
                                    .presentPaywallGuarded();
                              } on Exception catch (_) {}
                            },
                          ),
                  ),
                ],
              ),
            ),
            if (isOwnProfile) ...[
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.pushNamed(RouterPath.edit).then((value) {
                      if (value != null) {
                        ref
                            .read(myProfileViewModelProvider().notifier)
                            .setUser(value as Users);
                      }
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    t.profile.editButton,
                    style: TextStyle(
                      color: textColor87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Gap(12),
              const MemoryAlbumEntryCard(),
            ] else
              const Gap(8),
            if (users.isSubscribe)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.shade100,
                      Colors.amber.shade50,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.shade300,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade200.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.local_offer_outlined,
                                color: Colors.amber.shade700,
                                size: 24,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              t.profile.favoriteGenre,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                users.tag.isNotEmpty
                                    ? users.tag +
                                        getLocalizedCountryName(
                                          users.tag,
                                          context,
                                        )
                                    : t.post.selectFoodTag,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getRank(BuildContext context, int postCount) {
    final t = Translations.of(context);
    if (postCount >= 10000) {
      return t.rank.emerald;
    }
    if (postCount >= 5000) {
      return t.rank.diamond;
    }
    if (postCount >= 1000) {
      return t.rank.gold;
    }
    if (postCount >= 500) {
      return t.rank.silver;
    }
    return t.rank.bronze;
  }

  String _getTrophyAsset(int postCount) {
    if (postCount >= 10000) {
      return Assets.trophy.trophyEmerald.path;
    }
    if (postCount >= 5000) {
      return Assets.trophy.trophyDiamond.path;
    }
    if (postCount >= 1000) {
      return Assets.trophy.trophyGold.path;
    }
    if (postCount >= 500) {
      return Assets.trophy.trophySilver.path;
    }
    return Assets.trophy.trophyBronze.path;
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rankLabel,
    required this.trophyAsset,
    required this.isDark,
    required this.rankSuffix,
    required this.levelLabel,
  });

  final String rankLabel;
  final String trophyAsset;
  final bool isDark;
  final String rankSuffix;
  final String levelLabel;

  @override
  Widget build(BuildContext context) {
    final badgeBg = isDark ? const Color(0xFF3A2E1A) : Colors.amber.shade50;
    final badgeBorder =
        isDark ? const Color(0xFF8B7355) : Colors.amber.shade300;
    final badgeText = isDark ? const Color(0xFFE8C87A) : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            trophyAsset,
            width: 16,
            height: 16,
          ),
          const Gap(6),
          Flexible(
            child: Text(
              '$levelLabel $rankLabel $rankSuffix',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: badgeText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
