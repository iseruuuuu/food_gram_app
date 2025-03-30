import 'package:flutter/material.dart';

class StoryStyle {
  StoryStyle._();

  static TextStyle foodName() {
    return TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );
  }

  static TextStyle restaurant() {
    return TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
  }

  static TextStyle name() {
    return TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }
}
