import 'package:flutter/material.dart';

mixin SnackBarMixin {
  void openSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
