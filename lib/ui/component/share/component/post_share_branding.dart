import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:gap/gap.dart';

/// シェア画像の #FoodGram ブランディング
class PostShareBranding extends StatelessWidget {
  const PostShareBranding({
    this.lightBackground = false,
    this.showIcon = true,
    super.key,
  });

  final bool lightBackground;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final textColor = lightBackground ? const Color(0xFF2C2418) : Colors.white;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '#FoodGram',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: lightBackground ? 13 : 14,
          ),
        ),
        if (showIcon) ...[
          const Gap(4),
          Assets.icon.icon3.image(
            width: lightBackground ? 24 : 30,
            height: lightBackground ? 24 : 30,
          ),
        ],
      ],
    );
  }
}
