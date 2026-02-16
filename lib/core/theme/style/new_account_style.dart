import 'package:flutter/material.dart';

class NewAccountStyle {
  NewAccountStyle._();

  static TextStyle icon(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle title(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle contents(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 16,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
