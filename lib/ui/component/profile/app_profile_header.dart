import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/dialog/app_profile_dialog.dart';
import 'package:food_gram_app/ui/component/profile/app_profile_image.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/my_profile_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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
    final l10n = L10n.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final point = (heartAmount - users.exchangedPoint) / 10;
    final trophyAsset = _getTrophyAsset(length);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Assets.image.profileHeader.provider(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 50, bottom: 10),
              child: Column(
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Gap(8),
                        Text(
                          users.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (users.isSubscribe)
                          Row(
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
                  if (users.isSubscribe)
                    Column(
                      children: [
                        const Gap(8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade100,
                                Colors.amber.shade50,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                trophyAsset,
                                width: 25,
                                height: 25,
                              ),
                              const Gap(8),
                              Text(
                                '${_getRank(context, length)}${l10n.rank}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (users.selfIntroduce.isNotEmpty) ...[
                    const Gap(8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        users.selfIntroduce,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BuildStatColumn(
                        count: length.toString(),
                        label: l10n.profilePostCount,
                      ),
                      BuildStatColumn(
                        count: heartAmount.toString(),
                        label: l10n.postDetailLikeButton,
                      ),
                      if (currentUser == users.userId)
                        BuildStatColumn(
                          count: point.toString(),
                          label: l10n.profilePointCount,
                        ),
                    ],
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
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            l10n.profileEditButton,
                            style: const TextStyle(
                              color: Colors.black87,
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
                                      l10n.profileFavoriteGenre,
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
                                            ? users.tag
                                            : '未登録',
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
          top: 105,
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
                radius: 48,
                borderWidth: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getRank(BuildContext context, int postCount) {
    final l10n = L10n.of(context);
    if (postCount >= 10000) {
      return l10n.rankEmerald;
    }
    if (postCount >= 5000) {
      return l10n.rankDiamond;
    }
    if (postCount >= 1000) {
      return l10n.rankGold;
    }
    if (postCount >= 500) {
      return l10n.rankSilver;
    }
    return l10n.rankBronze;
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

class BuildStatColumn extends StatelessWidget {
  const BuildStatColumn({
    required this.count,
    required this.label,
    super.key,
  });

  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width / 3,
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
