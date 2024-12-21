import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    required this.onTap,
    required this.number,
    super.key,
  });

  final Function() onTap;
  final int number;

  @override
  Widget build(BuildContext context) {
    final imageSize = MediaQuery.of(context).size.width / 8;
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        'assets/icon/icon$number.png',
        width: imageSize,
        height: imageSize,
      ),
    );
  }
}
