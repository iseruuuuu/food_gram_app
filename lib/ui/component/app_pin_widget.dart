import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/component/food_tag_icon.dart';

/// ピン円の色。自分の投稿はブランドオレンジ、それ以外は赤。
enum _PinPalette {
  shared(
    gradient: [
      Color(0xFFFF6B6B),
      Color(0xFFE54033),
    ],
    shadow: Color(0xFFFF6B6B),
  ),
  own(
    gradient: [
      Color(0xFFFFB067),
      AppTheme.primaryOrange,
    ],
    shadow: AppTheme.primaryOrange,
  );

  const _PinPalette({
    required this.gradient,
    required this.shadow,
  });

  final List<Color> gradient;
  final Color shadow;

  static _PinPalette of({required bool isOwn}) => isOwn ? own : shared;
}

class AppPinWidget extends StatelessWidget {
  const AppPinWidget({
    required this.image,
    this.isOwn = false,
    super.key,
  });

  final String image;
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    final palette = _PinPalette.of(isOwn: isOwn);
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette.gradient,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.shadow.withValues(alpha: 0.3),
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
                      color: palette.shadow.withValues(alpha: 0.2),
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
    this.isOwn = false,
    super.key,
  });

  final String foodTag;

  /// 自分の投稿。円をブランドオレンジにする。
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    final palette = _PinPalette.of(isOwn: isOwn);

    /// foodTagが空の場合はデフォルトのピンアイコンを表示
    if (foodTag.isEmpty) {
      return AppPinWidget(
        image: Assets.image.pinIcon.path,
        isOwn: isOwn,
      );
    }
    // foodTagから最初のタグIDを取得（カンマ区切りの場合）
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette.gradient,
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
              child: FoodTagIcon(
                tagId: firstTag,
                size: 40,
                fit: BoxFit.cover,
                clipOval: true,
                expandToFill: true,
                centerText: true,
                imagePadding: const EdgeInsets.all(4),
                textStyle: const TextStyle(
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

/// 小さな赤ドットのピンウィジェット（ズーム13以下用）
/// 丸い赤の外に白色の円
class AppSmallRedDotWidget extends StatelessWidget {
  const AppSmallRedDotWidget({
    this.color = Colors.red,
    super.key,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    const size = 21.0;
    const innerSize = 16.8;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 1.5,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
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
