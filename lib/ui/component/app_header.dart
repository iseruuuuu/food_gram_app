import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:gap/gap.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.image,
    required this.length,
    required this.name,
    required this.userName,
    required this.selfIntroduce,
    super.key,
  });

  final String image;
  final int length;
  final String name;
  final String userName;
  final String selfIntroduce;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(image),
                radius: 50,
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
                    L10n.of(context).my_profile_post_length,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12),
            ],
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '@$userName',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          SizedBox(height: 4),
          Text(
            selfIntroduce,
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
