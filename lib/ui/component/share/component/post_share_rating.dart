import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// シェア画像キャプチャ時の device pixel ratio（例: 360pt → 1080px）
const double kPostShareCapturePixelRatio = 3;

String postShareImageUrl(WidgetRef ref, Posts posts) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.storage.from('food').getPublicUrl(posts.firstFoodImage);
}

class PostShareRating extends StatelessWidget {
  const PostShareRating({
    required this.star,
    this.color = Colors.white,
    this.iconSize = 18,
    this.fontSize = 16,
    super.key,
  });

  final double star;
  final Color color;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (star <= 0) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: iconSize,
        ),
        const Gap(4),
        Text(
          star.toStringAsFixed(1),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

const postShareSerifFontFamily = 'Times New Roman';

TextStyle postShareSerifTitleStyle({
  required double fontSize,
  required Color color,
  FontWeight fontWeight = FontWeight.w600,
}) {
  return TextStyle(
    fontFamily: postShareSerifFontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: 1.15,
  );
}
