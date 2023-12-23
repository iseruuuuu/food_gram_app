import 'package:flutter/material.dart';

class AppHeart extends StatelessWidget {
  const AppHeart({
    required this.isHeart,
    super.key,
  });

  final bool isHeart;

  @override
  Widget build(BuildContext context) {
    return isHeart
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/image/heart.gif',
                    width: 500,
                    height: 500,
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          )
        : SizedBox();
  }
}
