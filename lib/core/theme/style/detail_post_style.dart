import 'package:flutter/material.dart';

class DetailPostStyle {
  DetailPostStyle._();

  static TextStyle name() {
    return const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  static TextStyle userName() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    );
  }

  static TextStyle like() {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle foodName() {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  static TextStyle restaurant() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontFamily: 'Hiragino Kaku Gothic ProN',
      decoration: TextDecoration.underline,
      decorationThickness: 2,
    );
  }

  static TextStyle comment() {
    return const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
  }
}
