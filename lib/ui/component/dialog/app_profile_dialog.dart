import 'dart:ui';

import 'package:flutter/material.dart';

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
        content: CircleAvatar(
          radius: deviceWidth / 3.5,
          backgroundColor: Colors.white,
          foregroundImage: AssetImage(image),
        ),
      ),
    );
  }
}
