import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

/// 投稿 FAB への初回誘導オーバーレイ。
///
/// 発光する投稿ボタン + 「タップしてはじめよう！」→ 吹き出し。
class FirstPostGuideOverlay extends HookWidget {
  const FirstPostGuideOverlay({
    required this.buttonKey,
    required this.onTapPost,
    required this.onDismiss,
    super.key,
  });

  final GlobalKey buttonKey;
  final VoidCallback onTapPost;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    final buttonRect = useState<Rect?>(null);
    final overlayKey = useMemoized(GlobalKey.new);

    final pulseController = useAnimationController(
      duration: const Duration(milliseconds: 1400),
    );
    final bubbleController = useAnimationController(
      duration: const Duration(milliseconds: 450),
    );

    void updateButtonRect() {
      final buttonContext = buttonKey.currentContext;
      final overlayContext = overlayKey.currentContext;
      if (buttonContext == null || overlayContext == null) {
        return;
      }
      final box = buttonContext.findRenderObject() as RenderBox?;
      final overlayBox = overlayContext.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize || overlayBox == null) {
        return;
      }
      final globalOffset = box.localToGlobal(Offset.zero);
      final localOffset = overlayBox.globalToLocal(globalOffset);
      buttonRect.value = localOffset & box.size;
    }

    useEffect(
      () {
        pulseController.repeat(reverse: true);
        var cancelled = false;
        Timer? bubbleTimer;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (cancelled) {
            return;
          }
          updateButtonRect();
          bubbleTimer = Timer(const Duration(milliseconds: 900), () {
            if (!cancelled) {
              bubbleController.forward();
            }
          });
        });

        return () {
          cancelled = true;
          bubbleTimer?.cancel();
        };
      },
      [pulseController, bubbleController],
    );

    // FAB 座標が取れるまで再計測
    useEffect(
      () {
        if (buttonRect.value != null) {
          return null;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          updateButtonRect();
        });
        return null;
      },
      [buttonRect.value],
    );

    final rect = buttonRect.value;
    if (rect == null) {
      return Material(
        key: overlayKey,
        type: MaterialType.transparency,
        child: const SizedBox.expand(),
      );
    }

    final center = rect.center;
    final holeRadius = rect.width / 2 + 10;

    return Material(
      key: overlayKey,
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: CustomPaint(
                painter: _HoleMaskPainter(
                  holeCenter: center,
                  holeRadius: holeRadius,
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, child) {
              final pulse = Curves.easeInOut.transform(pulseController.value);
              final scale = 1.0 + pulse * 0.35;
              final opacity = 0.55 - pulse * 0.35;
              return Positioned(
                left: center.dx - holeRadius * scale,
                top: center.dy - holeRadius * scale,
                child: IgnorePointer(
                  child: Container(
                    width: holeRadius * 2 * scale,
                    height: holeRadius * 2 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD54F).withValues(alpha: opacity),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC107)
                              .withValues(alpha: opacity * 0.9),
                          blurRadius: 24 + pulse * 16,
                          spreadRadius: 4 + pulse * 8,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Phase1: タップ誘導テキスト
          Positioned(
            left: 24,
            right: 24,
            top: 0,
            height: math.max(0, rect.top - 16),
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: bubbleController,
                builder: (context, child) {
                  return Opacity(
                    opacity: (1 - bubbleController.value).clamp(0.0, 1.0),
                    child: child,
                  );
                },
                child: const Align(
                  alignment: Alignment.bottomCenter,
                  child: _TapHint(),
                ),
              ),
            ),
          ),
          // Phase2: 吹き出し
          Positioned(
            left: 28,
            right: 28,
            top: 0,
            height: math.max(0, rect.top - 12),
            child: IgnorePointer(
              child: FadeTransition(
                opacity: bubbleController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: bubbleController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _PromptBubble(
                      title: translations.firstPostGuide.promptTitle,
                      subtitle: translations.firstPostGuide.promptSubtitle,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTapPost,
                customBorder: const CircleBorder(),
                child: Ink(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TapHint extends StatelessWidget {
  const _TapHint();

  @override
  Widget build(BuildContext context) {
    final translations = Translations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          translations.firstPostGuide.tapHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const Gap(4),
        Icon(
          Icons.arrow_downward_rounded,
          color: Colors.white.withValues(alpha: 0.95),
          size: 28,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
            ),
          ],
        ),
      ],
    );
  }
}

class _PromptBubble extends StatelessWidget {
  const _PromptBubble({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppTheme.primaryBlue,
                  size: 26,
                ),
              ),
              const Gap(12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const Gap(8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: const Size(18, 10),
          painter: _BubbleTailPainter(color: colorScheme.surface),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  _BubbleTailPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _HoleMaskPainter extends CustomPainter {
  _HoleMaskPainter({
    required this.holeCenter,
    required this.holeRadius,
  });

  final Offset holeCenter;
  final double holeRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addOval(
        Rect.fromCircle(center: holeCenter, radius: holeRadius),
      );
    final path = Path.combine(PathOperation.difference, overlay, hole);
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _HoleMaskPainter oldDelegate) {
    return oldDelegate.holeCenter != holeCenter ||
        oldDelegate.holeRadius != holeRadius;
  }
}
