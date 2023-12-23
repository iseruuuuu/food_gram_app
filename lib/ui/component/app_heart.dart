import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class AppHeart extends StatelessWidget {
  const AppHeart({
    required this.isHeart,
    required this.controller,
    super.key,
  });

  final bool isHeart;
  final GifController controller;

  @override
  Widget build(BuildContext context) {
    return isHeart
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Gif(
                    controller: controller,
                    autostart: Autostart.once,
                    image: AssetImage('assets/image/heart.gif'),
                    onFetchCompleted: controller.stop,
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          )
        : SizedBox();
  }
}
