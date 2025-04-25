import 'package:flutter/material.dart';

class RestaurantStyle {
  RestaurantStyle._();

  static TextStyle name() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 15,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle address() {
    return const TextStyle(
      color: Colors.grey,
      fontSize: 11,
    );
  }
}
