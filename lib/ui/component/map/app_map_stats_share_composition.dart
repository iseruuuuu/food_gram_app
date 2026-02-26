import 'package:flutter/material.dart';

class AppMapStatsShareComposition extends StatelessWidget {
  const AppMapStatsShareComposition({
    required this.questionText,
    required this.child,
    super.key,
  });

  final String questionText;
  final Widget child;
  static const double compositionWidth = 360;
  static const double compositionHeight = 400;
  static const double cardWidth = 320;
  static const double cardHeight = 240;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compositionWidth,
      height: compositionHeight,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 56),
            Text(
              questionText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
