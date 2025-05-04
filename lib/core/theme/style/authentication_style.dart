import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';

class AuthenticationStyle {
  AuthenticationStyle._();

  static TextStyle foodGram() {
    return const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  static ButtonStyle signMail() {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    );
  }

  static TextStyle signMailText() {
    return const TextStyle(
      fontSize: 16,
      color: Colors.white,
    );
  }

  static AuthButtonStyle authButtonStyle(double width) {
    return AuthButtonStyle(
      shadowColor: Colors.grey,
      height: 50,
      elevation: 3,
      borderRadius: 10,
      width: width,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static TextStyle authTitleStyle() {
    return const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      letterSpacing: 2,
    );
  }

  static TextStyle authSubTitleStyle() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      letterSpacing: 2,
    );
  }
}
