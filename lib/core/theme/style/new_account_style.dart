import 'package:flutter/material.dart';

class NewAccountStyle {
  NewAccountStyle._();

  static TextStyle icon() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    );
  }

  static TextStyle title() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    );
  }

  static TextStyle contents() {
    return const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Colors.black,
    );
  }
}
