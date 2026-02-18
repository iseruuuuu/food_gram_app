import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';

class TextFormBorders {
  const TextFormBorders._();

  static const double _borderRadius = 15;
  static const double _borderWidth = 2;

  static const textFormFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
    borderSide: BorderSide(
      color: AppTheme.primaryBlue,
      width: _borderWidth,
    ),
  );

  static const textFormEnabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
    borderSide: BorderSide(
      color: Colors.grey,
    ),
  );

  static const textFormErrorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
    borderSide: BorderSide(
      color: Colors.red,
      width: _borderWidth,
    ),
  );

  /// ダークモード用（明るい色で視認性を確保）
  static const textFormFocusedBorderDark = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
    borderSide: BorderSide(
      color: AppTheme.primaryBlue,
      width: _borderWidth,
    ),
  );

  static const textFormEnabledBorderDark = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
    borderSide: BorderSide(
      color: Color(0xFF757575),
    ),
  );
}
