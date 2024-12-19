import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';

class AppProfileDialog extends StatelessWidget {
  const AppProfileDialog({
    required this.image,
    super.key,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: AlertDialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        content: AppProfileImage(
          imagePath: image,
          radius: deviceWidth / 3.5,
        ),
      ),
    );
  }
}
