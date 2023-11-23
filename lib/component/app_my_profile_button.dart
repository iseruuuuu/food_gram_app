import 'package:flutter/material.dart';

class AppMyProfileButton extends StatelessWidget {
  const AppMyProfileButton({
    required this.title,
    required this.onTap,
    super.key,
  });

  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        elevation: 5,
      ),
      onPressed: onTap,
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
