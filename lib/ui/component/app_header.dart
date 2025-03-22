import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:food_gram_app/ui/component/dialog/app_profile_dialog.dart';
import 'package:food_gram_app/ui/screen/my_profile/my_profile_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({
    required this.users,
    required this.length,
    required this.heartAmount,
    required this.isSubscription,
    super.key,
  });

  final Users users;
  final int length;
  final int heartAmount;
  final bool isSubscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final currentUser = ref.watch(currentUserProvider);
    final point = (heartAmount - users.exchangedPoint) / 10;
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
                    child: Text(
                      users.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                                    .getData();
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
                          child: const Text(
                            'プロフィールを編集',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
