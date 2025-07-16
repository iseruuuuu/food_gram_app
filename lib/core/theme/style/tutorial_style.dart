import 'package:flutter/material.dart';

class TutorialStyle {
  TutorialStyle._();

  static TextStyle title() {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle subTitle() {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
  }

  static TextStyle thirdTitle() {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle thirdSubTitle() {
    return const TextStyle(fontSize: 14);
  }

  static TextStyle accept() {
    return const TextStyle(fontSize: 18);
  }

  static TextStyle close() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }

  static ButtonStyle button() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
