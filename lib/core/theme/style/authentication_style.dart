import 'package:flutter/material.dart';

class AuthenticationStyle {
  AuthenticationStyle._();

  static TextStyle foodGram(BuildContext context) {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static ButtonStyle signMail(BuildContext context) {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    );
  }

  static TextStyle signMailText(BuildContext context) {
    return const TextStyle(
      fontSize: 16,
      color: Colors.white,
    );
  }

  static Color authButtonBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Colors.white;
  }

  static Color authButtonTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static OutlinedBorder authButtonShape(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(
        color: isDark
            ? Theme.of(context).colorScheme.outlineVariant
            : Colors.grey.shade300,
      ),
    );
  }

  static TextStyle authTitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
      letterSpacing: 2,
    );
  }

  static TextStyle authSubTitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
      letterSpacing: 2,
    );
  }
}
