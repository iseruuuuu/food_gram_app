import 'package:auth_buttons/auth_buttons.dart';
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
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    );
  }

  static TextStyle signMailText(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      color: Theme.of(context).colorScheme.onPrimary,
    );
  }

  static AuthButtonStyle authButtonStyle(BuildContext context, double width) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AuthButtonStyle(
      shadowColor: isDark ? Colors.transparent : Colors.grey,
      height: 50,
      elevation: isDark ? 0 : 3,
      borderRadius: 10,
      width: width,
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
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
