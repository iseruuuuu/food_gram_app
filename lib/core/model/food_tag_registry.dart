import 'package:food_gram_app/gen/assets.gen.dart';

/// DB保存・API送信用のカスタムタグID接頭辞（絵文字と区別する）
const customFoodTagPrefix = 'tag:';

/// assets/tag/ 配下の独自タグ定義
class CustomFoodTag {
  const CustomFoodTag({
    required this.id,
    required this.assetPath,
  });

  final String id;
  final String assetPath;
}

const Map<String, CustomFoodTag> customFoodTags = {
  'tag:udon': CustomFoodTag(
    id: 'tag:udon',
    assetPath: 'assets/tag/udon.png',
  ),
  'tag:soba': CustomFoodTag(
    id: 'tag:soba',
    assetPath: 'assets/tag/soba.png',
  ),
  'tag:yakisoba': CustomFoodTag(
    id: 'tag:yakisoba',
    assetPath: 'assets/tag/yakisoba.png',
  ),
  'tag:tonkatsu': CustomFoodTag(
    id: 'tag:tonkatsu',
    assetPath: 'assets/tag/tonkatsu.png',
  ),
};

bool isCustomFoodTag(String tagId) {
  return tagId.startsWith(customFoodTagPrefix);
}

String? customFoodTagAssetPath(String tagId) {
  return customFoodTags[tagId]?.assetPath;
}

/// カスタムタグIDから Assets.gen のパスを取得（存在しない場合は null）
String? customFoodTagAssetGenPath(String tagId) {
  switch (tagId) {
    case 'tag:udon':
      return Assets.tag.udon.path;
    case 'tag:soba':
      return Assets.tag.soba.path;
    case 'tag:yakisoba':
      return Assets.tag.yakisoba.path;
    case 'tag:tonkatsu':
      return Assets.tag.tonkatsu.path;
    default:
      return null;
  }
}
