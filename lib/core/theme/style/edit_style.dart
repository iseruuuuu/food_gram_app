import 'package:flutter/material.dart';

class EditStyle {
  EditStyle._();

  static TextStyle editButton({required bool loading}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: loading ? Colors.grey : Colors.blueAccent,
    );
  }

  static TextStyle settingsIcon() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
  }

  static TextStyle tag() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }
}
