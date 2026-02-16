import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';

class EditPostStyle {
  EditPostStyle._();

  static TextStyle editTitle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle editButton() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppTheme.primaryBlue,
    );
  }

  static TextStyle restaurant(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle category(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
