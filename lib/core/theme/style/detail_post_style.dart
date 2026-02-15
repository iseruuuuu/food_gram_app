import 'package:flutter/material.dart';

class DetailPostStyle {
  DetailPostStyle._();

  static Color _onSurface(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static TextStyle name(BuildContext context) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: _onSurface(context),
    );
  }

  static TextStyle userName(BuildContext context) {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.normal,
      color: _onSurface(context),
    );
  }

  static TextStyle like(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: _onSurface(context),
    );
  }

  static TextStyle foodName(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: _onSurface(context),
    );
  }

  static TextStyle restaurant(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: _onSurface(context),
      fontFamily: 'Hiragino Kaku Gothic ProN',
      decoration: TextDecoration.underline,
      decorationThickness: 2,
    );
  }

  static TextStyle comment(BuildContext context) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: _onSurface(context),
    );
  }
}
