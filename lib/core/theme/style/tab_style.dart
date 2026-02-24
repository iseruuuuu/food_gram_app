import 'package:flutter/material.dart';

class TabStyle {
  TabStyle._();

  /// タブ（アイコン・文言）の色。ライトモードでは選択時は黒、未選択は灰色。ダークモードでは選択/未選択とも白で統一。
  static Color tabColor(BuildContext context, {required bool selected}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Colors.white;
    }
    return selected ? Colors.black : Colors.grey;
  }

  static TextStyle tab(BuildContext context, {required bool value}) {
    return TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: tabColor(context, selected: value),
    );
  }
}
