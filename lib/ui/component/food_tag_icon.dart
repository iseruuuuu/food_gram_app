import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/food_tag_registry.dart';

/// 食べ物タグのアイコン表示（絵文字 or assets/tag/ の画像）
class FoodTagIcon extends StatelessWidget {
  const FoodTagIcon({
    required this.tagId,
    this.size = 24,
    this.textStyle,
    this.fit = BoxFit.contain,
    this.clipOval = false,
    this.imagePadding,
    this.expandToFill = false,
    this.centerText = false,
    super.key,
  });

  final String tagId;
  final double size;
  final TextStyle? textStyle;
  final BoxFit fit;
  final bool clipOval;
  final EdgeInsetsGeometry? imagePadding;
  final bool expandToFill;
  final bool centerText;

  @override
  Widget build(BuildContext context) {
    final assetPath = customFoodTagAssetPath(tagId);
    if (assetPath != null) {
      Widget image = Image.asset(
        assetPath,
        width: expandToFill ? null : size,
        height: expandToFill ? null : size,
        fit: fit,
      );
      if (expandToFill) {
        image = SizedBox.expand(child: image);
      }
      if (imagePadding != null) {
        image = Padding(padding: imagePadding!, child: image);
      }
      if (clipOval) {
        image = ClipOval(child: image);
      }
      return image;
    }

    final text = Text(
      tagId,
      style: textStyle ?? TextStyle(fontSize: size * 0.75),
    );
    return centerText ? Center(child: text) : text;
  }
}
