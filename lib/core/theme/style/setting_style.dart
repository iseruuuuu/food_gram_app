import 'package:flutter/material.dart';

class SettingStyle {
  SettingStyle._();

  /// サブスクバナー用（色はそのまま）
  static TextStyle premium() {
    return const TextStyle(
      fontSize: 13,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle appVersion(BuildContext context) {
    return TextStyle(color: Theme.of(context).colorScheme.onSurface);
  }

  static TextStyle version(BuildContext context) {
    return TextStyle(
      fontSize: 18,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
