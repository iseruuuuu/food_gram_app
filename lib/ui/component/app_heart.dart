import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:lottie/lottie.dart';

class AppHeart extends HookWidget {
  const AppHeart({
    required this.isHeart,
    super.key,
  });

  final bool isHeart;

  @override
  Widget build(BuildContext context) {
    final showHeart = useState(false);
    useEffect(
      () {
        if (isHeart) {
          showHeart.value = true;
          Future.delayed(const Duration(milliseconds: 1200), () {
            showHeart.value = false;
          });
        }
        return null;
      },
      [isHeart],
    );

    return showHeart.value
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  Assets.lottie.heart,
                  repeat: false,
                  width: 600,
                  height: 600,
                ),
                const SizedBox(height: 100),
              ],
            ),
          )
        : const SizedBox();
  }
}
