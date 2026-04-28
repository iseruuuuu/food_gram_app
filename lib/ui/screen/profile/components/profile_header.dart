import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    const avatarRadius = 48.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Assets.image.profileHeader.provider(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: headerBg,
              padding: const EdgeInsets.only(top: 50, bottom: 10),
              child: Column(
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Gap(8),
                        Text(
                          users.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        if (currentUser == users.userId) ...[
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
                              UserLevel.levelFromPostCount(length) >=
                                      UserLevel.maxLevel
                                  ? t.profile.levelMax
                                  : t.profile.levelLabel.replaceAll(
                                      '{level}',
                                      UserLevel.levelFromPostCount(length)
                                          .toString(),
                                    ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                        if (users.isSubscribe)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Gap(8),
                              Assets.image.profileIcon.image(
                                width: 30,
                                height: 30,
                              ),
                            ],
                          ),
                        const Gap(4),
                      ],
                    ),
                  ),
                  if (users.selfIntroduce.isNotEmpty) ...[
                    const Gap(8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        users.selfIntroduce,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor87,
                        ),
                      ),
                    ),
                  ],
                  if (currentUser == users.userId) ...[
                    const Gap(8),
                    if (UserLevel.levelFromPostCount(length) <
                        UserLevel.maxLevel)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(
                              builder: (context) {
                                final parts =
                                    t.profile.nextLevelBanner.split('{count}');
                                final count =
                                    UserLevel.postsNeededForNextLevel(length) ??
                                        0;
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
                                backgroundColor: isDark
                                    ? Colors.white12
                                    : Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  const Gap(24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ProfileStat(
                              icon: Icons.restaurant_rounded,
                              iconBg: const Color(0xFFFFF3CD),
                              iconColor: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                              valueText: length.toString(),
                              label: t.profile.postCount,
                              textColor: textColor,
                              mutedColor:
                                  isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          VerticalDivider(
                            width: 17,
                            thickness: 1,
                            indent: 6,
                            endIndent: 6,
                            color:
                                isDark ? Colors.white24 : Colors.grey.shade300,
                          ),
                          Expanded(
                            child: ProfileStat(
                              icon: Icons.favorite_rounded,
                              iconBg: const Color(0xFFFFE4EC),
                              iconColor: Colors.red.shade400,
                              valueText: heartAmount.toString(),
                              label: t.likeButton,
                              textColor: textColor,
                              mutedColor:
                                  isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          VerticalDivider(
                            width: 17,
                            thickness: 1,
                            indent: 6,
                            endIndent: 6,
                            color:
                                isDark ? Colors.white24 : Colors.grey.shade300,
                          ),
                          Expanded(
                            child: rankingUnlocked
                                ? ProfileRankingUnlocked(
                                    userId: users.userId,
                                    textColor: textColor,
                                    mutedColor: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    rankingLabel: t.profile.rankingStats,
                                    ref: ref,
                                  )
                                : ProfileRankingLocked(
                                    textColor: textColor,
                                    mutedColor: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    rankingLabel: t.profile.rankingStats,
                                    memberOnlyLabel: t.profile.memberOnlyBadge,
                                    isDark: isDark,
                                    onTap: () async {
                                      try {
                                        await ref
                                            .read(
                                              revenueCatServiceProvider
                                                  .notifier,
                                            )
                                            .presentPaywallGuarded();
                                      } on Exception catch (_) {}
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (currentUser == users.userId)
                    const Gap(16)
                  else
                    const Gap(8),
                  if (currentUser == users.userId)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
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
                    ),
                  if (users.isSubscribe)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
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
                                  color: Colors.amber.shade200
                                      .withValues(alpha: 0.3),
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
                                            color: Colors.amber
                                                .withValues(alpha: 0.1),
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
                                        color:
                                            Colors.amber.withValues(alpha: 0.1),
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
                    ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 130,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (_) {
                    return AppProfileDialog(image: users.image);
                  },
                );
              },
              child: AppProfileImage(
                imagePath: users.image,
                radius: avatarRadius,
                borderWidth: 4,
                borderColor: headerBg,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
