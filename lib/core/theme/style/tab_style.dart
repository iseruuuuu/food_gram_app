import 'package:flutter/material.dart';

class TabStyle {
  TabStyle._();

  /// タブ（アイコン・文言）の色。
  /// ライト: 選択時は黒 / 未選択は灰色。ダーク: 選択時は白 / 未選択は灰色。
  static Color tabColor(BuildContext context, {required bool selected}) {
    if (!selected) {
      return Colors.grey;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black;
  }

  static TextStyle tab(BuildContext context, {required bool value}) {
    return TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: tabColor(context, selected: value),
    );
  }
}
