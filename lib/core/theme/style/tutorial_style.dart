import 'package:flutter/material.dart';

class TutorialStyle {
  TutorialStyle._();

  static TextStyle title() {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle subTitle() {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
  }

  static TextStyle thirdTitle() {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle thirdSubTitle() {
    return TextStyle(fontSize: 14);
  }

  static TextStyle accept() {
    return TextStyle(fontSize: 18);
  }

  static TextStyle close() {
    return TextStyle(
      color: Colors.white,
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
