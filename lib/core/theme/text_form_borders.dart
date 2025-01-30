import 'package:flutter/material.dart';

class TextFormBorders {
  const TextFormBorders._();

  static const double _borderRadius = 15;
  static const double _borderWidth = 2;

  static const textFormFocusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
    borderSide: BorderSide(
      color: Colors.blue,
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
}
