import 'package:flutter/material.dart';

class PaywallStyle {
  PaywallStyle._();

  static TextStyle title() {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  static TextStyle premiumTitle() {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.amber[700],
    );
  }

  static TextStyle comingSoon() {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  static TextStyle newFeatures() {
    return TextStyle(
      fontSize: 12,
      color: Colors.white.withValues(alpha: 0.8),
    );
  }

  static ButtonStyle button() {
    return ElevatedButton.styleFrom(
      elevation: 10,
      backgroundColor: Colors.amber[700],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  static TextStyle wellComeTitle() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
      color: Colors.white,
    );
  }

  static TextStyle subscribeButton() {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle price() {
    return TextStyle(
      fontSize: 14,
      color: Colors.white.withValues(alpha: 0.8),
    );
  }

  static TextStyle contentsTitle() {
    return TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.amber[700],
    );
  }

  static TextStyle contentsDescription() {
    return const TextStyle(
      fontSize: 14,
      color: Colors.black,
    );
  }
}
