import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/style/paywall_style.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class PaywallSuccessDialog extends StatelessWidget {
  const PaywallSuccessDialog({
    required this.controller,
    required this.t,
    this.timeoutDuration = const Duration(seconds: 3),
    super.key,
  });

  final ConfettiController controller;
  final Translations t;
  final Duration timeoutDuration;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      title: SizedBox(
        height: 550,
        child: Column(
          children: [
            Center(
              child: Container(
                width: 200,
                height: 0,
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: controller,
                  blastDirectionality: BlastDirectionality.explosive,
                  emissionFrequency: 1,
                  numberOfParticles: 30,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  gravity: 0.3,
                  createParticlePath: drawStar,
                ),
              ),
            ),
            const Spacer(),
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 10,
              ),
              child: Column(
                children: [
                  Text(
                    t.paywallWelcomeTitle,
                    style: PaywallStyle.wellComeTitle(),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(30),
                  Assets.image.present.image(
                    width: 200,
                    height: 200,
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

Future<void> showPaywallSuccessDialog({
  required BuildContext context,
  required ConfettiController controller,
  Duration timeoutDuration = const Duration(seconds: 3),
}) async {
  final t = Translations.of(context);
  try {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (_) {
        return PaywallSuccessDialog(
          controller: controller,
          t: t,
          timeoutDuration: timeoutDuration,
        );
      },
    ).timeout(timeoutDuration);
  } on TimeoutException {
    if (context.mounted) {
      context.pop();
    }
  }
}

Path drawStar(Size size) {
  double degToRad(double deg) => deg * (pi / 180.0);

  const numberOfPoints = 5;
  final halfWidth = size.width / 2;
  final externalRadius = halfWidth;
  final internalRadius = halfWidth / 2.5;
  final degreesPerStep = degToRad(360 / numberOfPoints);
  final halfDegreesPerStep = degreesPerStep / 2;
  final path = Path();
  final fullAngle = degToRad(360);
  path.moveTo(size.width, halfWidth);

  for (var step = 0.0; step < fullAngle; step += degreesPerStep) {
    path
      ..lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      )
      ..lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
  }
  path.close();
  return path;
}
