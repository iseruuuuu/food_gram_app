import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/food_tag_registry.dart';

/// 食べ物タグのアイコン表示（絵文字 or assets/tag/ の画像）
class FoodTagIcon extends StatelessWidget {
  const FoodTagIcon({
    required this.tagId,
    this.size = 24,
    super.key,
  });

  final String tagId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final assetPath = customFoodTagAssetPath(tagId);
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }
    return Text(
      tagId,
      style: TextStyle(fontSize: size * 0.75),
    );
  }
}
