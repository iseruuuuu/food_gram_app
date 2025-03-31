import 'package:flutter/material.dart';

class ProfileStyle {
  ProfileStyle._();

  static TextStyle name() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );
  }

  static TextStyle userName() {
    return TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: Colors.grey,
    );
  }
}
