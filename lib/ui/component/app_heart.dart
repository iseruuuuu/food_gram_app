import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
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
                    image: AssetImage(Assets.image.heart.path),
                    onFetchCompleted: controller.stop,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          )
        : const SizedBox();
  }
}
