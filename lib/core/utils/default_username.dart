import 'dart:math';

/// 初回登録で使う仮ユーザー名の接頭辞。
const defaultUsernamePrefix = 'FoodGrammer';

/// 初回登録で使うデフォルトアイコン（`assets/icon/icon1.png`）。
const defaultProfileIconNumber = 1;

/// `FoodGrammer 2847` 形式の仮ユーザー名を生成する。
String generateDefaultUsername([Random? random]) {
  final number = (random ?? Random()).nextInt(10000);
  return '$defaultUsernamePrefix ${number.toString().padLeft(4, '0')}';
}
