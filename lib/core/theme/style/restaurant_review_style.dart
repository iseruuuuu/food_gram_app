import 'package:flutter/material.dart';

class RestaurantReviewStyle {
  RestaurantReviewStyle._();

  static TextStyle restaurant([Color? color]) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
}
