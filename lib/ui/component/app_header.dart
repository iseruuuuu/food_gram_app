import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/dialog/app_profile_dialog.dart';
import 'package:gap/gap.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.users,
    required this.length,
    required this.heartAmount,
    super.key,
  });

  final Users users;
  final int length;
  final int heartAmount;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) {
                      return AppProfileDialog(image: users.image);
                    },
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(users.image),
                  radius: 50,
                ),
              ),
              Spacer(),
              Assets.gif.myProfile.image(width: 50, height: 50),
              Gap(30),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$length',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.profilePostCount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Gap(30),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${heartAmount - users.exchangedPoint}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.profilePointCount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            users.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '@${users.userName}',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 4),
          Text(
            users.selfIntroduce,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}
