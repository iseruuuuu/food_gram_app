import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/theme/style/profile_style.dart';
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
import 'package:intl/intl.dart';

class AppProfileHeader extends ConsumerWidget {
  const AppProfileHeader({
    required this.users,
    required this.length,
    required this.heartAmount,
    super.key,
  });

  final Users users;
  final int length;
  final int heartAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final isViewerSubscribed =
        ref.watch(isSubscribeProvider).valueOrNull ?? false;
    const avatarRadius = 60.0;
    final level = UserLevel.levelFromPostCount(length);
    final isOwnProfile = currentUser == users.userId;
    final iconBg = AppTheme.orangeBackgroundOf(context);
    const iconColor = AppTheme.primaryOrange;
    final dividerColor = AppTheme.dividerOf(context);

    return ColoredBox(
      color: AppTheme.backgroundOf(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final isDefaultIcon =
                        AppProfileImage.isDefaultIcon(users.image);
                    final isSubscribed =
                        users.isSubscribe || isViewerSubscribed;
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
                              style: ProfileStyle.displayName(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (users.isSubscribe) ...[
                            const Gap(6),
                            Opacity(
                              opacity: 0.78,
                              child: Assets.image.profileIcon.image(
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (isOwnProfile) ...[
                        const Gap(4),
                        FittedBox(
                          child: Text(
                            t.profile.memberNumber.replaceAll(
                              '{number}',
                              NumberFormat.decimalPattern(
                                Localizations.localeOf(context).toLanguageTag(),
                              ).format(users.id),
                            ),
                            style: ProfileStyle.memberNumber(context),
                          ),
                        ),
                      ],
                      const Gap(8),
                      _RankBadge(
                        rankLabel: _getRank(context, length),
                        trophyAsset: _getTrophyAsset(length),
                        rankSuffix: t.rank.label,
                        levelLabel: level >= UserLevel.maxLevel
                            ? t.profile.levelMax
                            : t.profile.levelLabel.replaceAll(
                                '{level}',
                                level.toString(),
                              ),
                      ),
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
                style: ProfileStyle.bio(context),
              ),
            ],
            if (isOwnProfile && level < UserLevel.maxLevel) ...[
              const Gap(8),
              Builder(
                builder: (context) {
                  final parts = t.profile.nextLevelBanner.split('{count}');
                  final count = UserLevel.postsNeededForNextLevel(length) ?? 0;
                  final nextLevelStyle = ProfileStyle.nextLevel(context);
                  if (parts.length != 2) {
                    return Text(
                      t.profile.nextLevelBanner.replaceAll(
                        '{count}',
                        count.toString(),
                      ),
                      style: nextLevelStyle,
                    );
                  }
                  return RichText(
                    text: TextSpan(
                      style: nextLevelStyle.copyWith(fontSize: 15),
                      children: [
                        TextSpan(text: parts[0]),
                        TextSpan(
                          text: count.toString(),
                          style: ProfileStyle.nextLevelCount(context),
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
                  backgroundColor: iconBg,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryOrange,
                  ),
                ),
              ),
            ],
            const Gap(16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ProfileStat(
                      icon: Icons.restaurant_rounded,
                      iconBg: iconBg,
                      iconColor: iconColor,
                      valueText: length.toString(),
                      label: t.profile.postCount,
                    ),
                  ),
                  VerticalDivider(
                    width: 17,
                    thickness: 1,
                    indent: 6,
                    endIndent: 6,
                    color: dividerColor,
                  ),
                  Expanded(
                    child: ProfileStat(
                      icon: Icons.favorite_rounded,
                      iconBg: iconBg,
                      iconColor: iconColor,
                      valueText: heartAmount.toString(),
                      label: t.likeButton,
                    ),
                  ),
                  VerticalDivider(
                    width: 17,
                    thickness: 1,
                    indent: 6,
                    endIndent: 6,
                    color: dividerColor,
                  ),
                  Expanded(
                    child: ProfileRankingUnlocked(
                      userId: users.userId,
                      rankingLabel: t.profile.rankingStats,
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
                    side: BorderSide(color: dividerColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    t.profile.editButton,
                    style: ProfileStyle.editButton(context),
                  ),
                ),
              ),
              const Gap(12),
              const MemoryAlbumEntryCard(),
            ] else
              const Gap(8),
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
    required this.rankSuffix,
    required this.levelLabel,
  });

  final String rankLabel;
  final String trophyAsset;
  final String rankSuffix;
  final String levelLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ProfileStyle.rankBadgeBackground(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ProfileStyle.rankBadgeBorder(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              AppTheme.primaryOrange,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              trophyAsset,
              width: 16,
              height: 16,
            ),
          ),
          const Gap(6),
          Flexible(
            child: Text(
              '$levelLabel $rankLabel $rankSuffix',
              style: ProfileStyle.rankBadge(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
