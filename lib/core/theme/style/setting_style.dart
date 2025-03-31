import 'package:flutter/material.dart';

class SettingStyle {
  SettingStyle._();

  static TextStyle premium() {
    return TextStyle(
      fontSize: 13,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle appVersion() {
    return TextStyle(color: Colors.black);
  }

  static TextStyle version() {
    return TextStyle(
      fontSize: 18,
      color: Colors.black,
    );
  }
}
