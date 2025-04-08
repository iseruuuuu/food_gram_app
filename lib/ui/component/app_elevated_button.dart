import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton({
    required this.onPressed,
    required this.title,
    super.key,
  });

  final VoidCallback onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 100,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class AppDetailElevatedButton extends StatelessWidget {
  const AppDetailElevatedButton({
    required this.onPressed,
    required this.title,
    required this.icon,
    super.key,
  });

  final VoidCallback onPressed;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          elevation: 0,
          backgroundColor: const Color(0xFFEFEFEF),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: 20,
            ),
            const Gap(4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
