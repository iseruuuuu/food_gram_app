import 'package:flutter/material.dart';

class TabStyle {
  TabStyle._();

  static TextStyle tab({required bool value}) {
    return TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: value ? Colors.black : Colors.grey,
    );
  }
}
