import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';

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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6B6B),
                    Color(0xFFE54033),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: ClipOval(
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
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
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Color(0xFFF5F5F5),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppFoodTagPinWidget extends StatelessWidget {
  const AppFoodTagPinWidget({
    required this.foodTag,
    super.key,
  });

  final String foodTag;

  @override
  Widget build(BuildContext context) {
    /// foodTagが空の場合はデフォルトのピンアイコンを表示
    if (foodTag.isEmpty) {
      return AppPinWidget(image: Assets.image.pinIcon.path);
    }
    // foodTagから最初の絵文字を取得（カンマ区切りの場合）
    final firstTag = foodTag.split(',').first.trim();
    return Container(
      width: 44,
      height: 58,
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            top: 2,
            left: 2,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6B6B),
                    Color(0xFFE54033),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  firstTag,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 36,
            left: 8,
            child: Stack(
              children: [
                Positioned(
                  top: 1,
                  left: 1,
                  child: ClipPath(
                    clipper: TriangleClipper(),
                    child: Container(
                      width: 24,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                ClipPath(
                  clipper: TriangleClipper(),
                  child: Container(
                    width: 24,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Color(0xFFF5F5F5),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
