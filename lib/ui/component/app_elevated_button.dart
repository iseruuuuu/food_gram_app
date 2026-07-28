import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton({
    required this.onPressed,
    required this.title,
    this.backgroundColor,
    this.horizontalInset = 100,
    super.key,
  });

  final VoidCallback onPressed;
  final String title;
  final Color? backgroundColor;
  final double horizontalInset;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = backgroundColor ?? Colors.black;
    return Container(
      width: MediaQuery.of(context).size.width - horizontalInset,
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? null : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isDark && backgroundColor == null
                ? const BorderSide(color: Colors.white54)
                : BorderSide.none,
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFEFEFEF);
    final fgColor = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          elevation: 0,
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: isDark
                ? const BorderSide(color: Colors.white54)
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(
              icon,
              color: fgColor,
              size: 20,
            ),
            const Gap(4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: fgColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
