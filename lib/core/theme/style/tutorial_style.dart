import 'package:flutter/material.dart';

class TutorialStyle {
  TutorialStyle._();

  static TextStyle title(BuildContext context) {
    return TextStyle(
      fontSize: 23,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle notificationTitle(BuildContext context) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      height: 1.4,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle subTitle(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle notificationSubTitle(BuildContext context) {
    return TextStyle(
      fontSize: 15,
      height: 1.55,
      fontWeight: FontWeight.normal,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
    );
  }

  static TextStyle thirdTitle(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle thirdSubTitle(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle accept(BuildContext context) {
    return TextStyle(
      fontSize: 18,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle close(BuildContext context) {
    return const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
  }

  static ButtonStyle button(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
