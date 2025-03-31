import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';

class AuthenticationStyle {
  AuthenticationStyle._();

  static TextStyle foodGram() {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  static ButtonStyle signMail() {
    return ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    );
  }

  static TextStyle signMailText() {
    return TextStyle(
      fontSize: 16,
      color: Colors.white,
    );
  }

  static AuthButtonStyle authButtonStyle(double width) {
    return AuthButtonStyle(
      splashColor: Colors.white,
      height: 50,
      elevation: 3,
      borderRadius: 20,
      width: width,
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
