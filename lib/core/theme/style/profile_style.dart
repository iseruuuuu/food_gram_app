import 'package:flutter/material.dart';

class ProfileStyle {
  ProfileStyle._();

  static TextStyle name() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );
  }

  static TextStyle userName() {
    return const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 14,
      color: Colors.grey,
    );
  }
}
