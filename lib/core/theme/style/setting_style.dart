import 'package:flutter/material.dart';

class SettingStyle {
  SettingStyle._();

  static TextStyle premium() {
    return const TextStyle(
      fontSize: 13,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle appVersion() {
    return const TextStyle(color: Colors.black);
  }

  static TextStyle version() {
    return const TextStyle(
      fontSize: 18,
      color: Colors.black,
    );
  }
}
