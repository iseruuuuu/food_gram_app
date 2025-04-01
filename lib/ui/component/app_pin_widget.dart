import 'package:flutter/material.dart';

class AppPinWidget extends StatelessWidget {
  const AppPinWidget({
    required this.image,
    super.key,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 54,
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Image.asset(image),
              ),
            ),
          ),
          Positioned(
            top: 36,
            left: 8,
            child: ClipPath(
              clipper: TriangleClipper(),
              child: Container(
                width: 24,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 三角形のクリッパー
class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
