import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:food_gram_app/ui/component/dialog/app_profile_dialog.dart';
import 'package:gap/gap.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({
    required this.users,
    required this.length,
    required this.heartAmount,
    required this.isSubscription,
    super.key,
  });

  final Users users;
  final int length;
  final int heartAmount;
  final bool isSubscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textSpan = TextSpan(
            text: users.selfIntroduce,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth - 32);
          final lineHeight =
              textPainter.height / textPainter.computeLineMetrics().length;
          var selfIntroduceLines = 3;
          if (users.selfIntroduce.isEmpty) {
            selfIntroduceLines = 0;
          } else if (textPainter.height <= lineHeight) {
            selfIntroduceLines = 1;
          } else if (textPainter.height <= lineHeight * 2) {
            selfIntroduceLines = 2;
          }
          final containerHeight = 150 + (selfIntroduceLines * 18);
          return Container(
            height: containerHeight.toDouble(),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: Offset(0, -4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                if (isSubscription)
                  Positioned.fill(child: AnimatedGradientBackground()),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog<void>(
                                context: context,
                                builder: (_) {
                                  return AppProfileDialog(image: users.image);
                                },
                              );
                            },
                            child: AppProfileImage(
                              imagePath: users.image,
                              radius: 42,
                            ),
                          ),
                          Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$length',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                l10n.profilePostCount,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Gap(30),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${heartAmount - users.exchangedPoint}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                l10n.profilePointCount,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Gap(8),
                      Text(
                        users.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Gap(4),
                      if (selfIntroduceLines != 0)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: SizedBox(
                              height: lineHeight * selfIntroduceLines,
                              child: Text(
                                users.selfIntroduce,
                                maxLines: selfIntroduceLines,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 0,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  @override
  AnimatedGradientBackgroundState createState() =>
      AnimatedGradientBackgroundState();
}

class AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.6),
                Colors.grey.withValues(alpha: 0.4),
                Colors.blueGrey.withValues(alpha: 0.4),
              ],
              stops: [
                0.3,
                0.6,
                1.0,
              ],
              transform:
                  GradientRotation(_controller.value * 2.0 * 3.14159265359),
            ).createShader(rect);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      },
    );
  }
}
