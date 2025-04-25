import 'package:flutter/material.dart';

class StoryStyle {
  StoryStyle._();

  static TextStyle foodName() {
    return const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );
  }

  static TextStyle restaurant() {
    return const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
  }

  static TextStyle name() {
    return const TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }
}
