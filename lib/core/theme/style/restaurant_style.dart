import 'package:flutter/material.dart';

class RestaurantStyle {
  RestaurantStyle._();

  static TextStyle name(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 15,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle address(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 11,
    );
  }
}
