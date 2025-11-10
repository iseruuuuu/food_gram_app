import 'package:flutter/material.dart';

class PaywallStyle {
  PaywallStyle._();

  static TextStyle title() {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  static TextStyle premiumTitle() {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
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
      padding: const EdgeInsets.symmetric(vertical: 14),
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
    return const TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle contentsTitle() {
    return const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  static TextStyle contentsDescription() {
    return const TextStyle(
      fontSize: 14,
      color: Colors.black,
    );
  }
}
