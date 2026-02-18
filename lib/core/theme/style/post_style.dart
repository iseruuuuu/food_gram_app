import 'package:flutter/material.dart';

class PostStyle {
  PostStyle._();

  static TextStyle title(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle share(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle restaurant(BuildContext context, {required bool value}) {
    final scheme = Theme.of(context).colorScheme;
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: value ? scheme.onSurfaceVariant : scheme.onSurface,
    );
  }

  static TextStyle categoryTitle(BuildContext context) {
    return TextStyle(
      fontSize: 18,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
