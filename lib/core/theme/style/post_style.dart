import 'package:flutter/material.dart';

class PostStyle {
  PostStyle._();

  static TextStyle title() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  static TextStyle share() {
    return const TextStyle(
      fontSize: 16,
      color: Colors.blue,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle restaurant({required bool value}) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: value ? Colors.grey : Colors.black,
    );
  }

  static TextStyle categoryTitle() {
    return const TextStyle(fontSize: 16);
  }
}
