import 'package:flutter/material.dart';

class EditStyle {
  EditStyle._();

  static TextStyle editButton(BuildContext context, {required bool loading}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: loading
          ? (isDark ? Colors.white54 : Colors.grey)
          : Theme.of(context).colorScheme.primary,
    );
  }

  static TextStyle settingsIcon(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle tag(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
