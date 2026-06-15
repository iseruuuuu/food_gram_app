import 'package:flutter/material.dart';

class PostStyle {
  PostStyle._();

  static const requiredAccent = Color(0xFFE8437A);
  static const requiredSectionBg = Color(0xFFFFF5F7);
  static const requiredSectionBorder = Color(0xFFFFC2D4);
  static const optionalAccent = Color(0xFF3B8BEB);
  static const optionalSectionBg = Color(0xFFF0F7FF);
  static const optionalSectionBorder = Color(0xFFB8D9F8);
  static const fieldBorder = Color(0xFFE0E0E0);
  static const hintColor = Color(0xFF9E9E9E);

  static Color requiredBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? requiredAccent.withValues(alpha: 0.08)
        : requiredSectionBg;
  }

  static Color requiredBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? requiredAccent.withValues(alpha: 0.35)
        : requiredSectionBorder;
  }

  static Color optionalBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? optionalAccent.withValues(alpha: 0.08)
        : optionalSectionBg;
  }

  static Color optionalBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? optionalAccent.withValues(alpha: 0.35)
        : optionalSectionBorder;
  }

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

  static TextStyle sectionTitle(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle sectionSubtitle(BuildContext context) {
    return TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle sectionHint(Color accent) {
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: accent,
    );
  }

  static TextStyle fieldLabel(Color accent) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: accent,
    );
  }

  static TextStyle fieldHint(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.onSurfaceVariant
          : hintColor,
    );
  }

  static TextStyle fieldValue(BuildContext context) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
