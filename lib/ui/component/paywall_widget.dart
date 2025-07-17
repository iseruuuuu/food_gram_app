import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/style/paywall_style.dart';
import 'package:food_gram_app/core/theme/style/tutorial_style.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class PaywallBackground extends StatelessWidget {
  const PaywallBackground({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.image.paywallBackground.path),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.4),
          child: child,
        ),
      ),
    );
  }
}

class PaywallFeatureItem extends StatelessWidget {
  const PaywallFeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    this.padding = const EdgeInsets.all(8),
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.amber[700], size: 30),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PaywallStyle.contentsTitle(),
                ),
                Text(
                  description,
                  style: PaywallStyle.contentsDescription(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaywallCardBase extends StatelessWidget {
  const PaywallCardBase({
    required this.isPaywall,
    super.key,
  });

  final bool isPaywall;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple[400]!,
            Colors.blue[400]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.rocket_launch, color: Colors.white),
          ),
          const Gap(12),
          Expanded(
            child: isPaywall
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.paywallComingSoon,
                        style: PaywallStyle.comingSoon(),
                      ),
                      Text(
                        l10n.paywallNewFeatures,
                        style: PaywallStyle.newFeatures(),
                      ),
                    ],
                  )
                : Text(
                    l10n.paywallPrice,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class PaywallContent extends StatelessWidget {
  const PaywallContent({
    required this.onPurchase,
    this.onSkip,
    this.showComingSoon = false,
    this.showSkipButton = false,
    super.key,
  });

  final VoidCallback onPurchase;
  final VoidCallback? onSkip;
  final bool showComingSoon;
  final bool showSkipButton;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.paywallPremiumTitle,
            style: PaywallStyle.premiumTitle(),
          ),
          const Gap(16),
          PaywallFeatureItem(
            icon: Icons.emoji_events,
            title: l10n.paywallTrophyTitle,
            description: l10n.paywallTrophyDesc,
          ),
          PaywallFeatureItem(
            icon: Icons.label,
            title: l10n.paywallTagTitle,
            description: l10n.paywallTagDesc,
          ),
          PaywallFeatureItem(
            icon: Icons.account_circle,
            title: l10n.paywallIconTitle,
            description: l10n.paywallIconDesc,
          ),
          PaywallFeatureItem(
            icon: Icons.block,
            title: l10n.paywallAdTitle,
            description: l10n.paywallAdDesc,
          ),
          PaywallCardBase(isPaywall: showComingSoon),
          if (showSkipButton)
            Column(
              children: [
                const Gap(20),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: PaywallStyle.button(),
                    onPressed: onPurchase,
                    child: FittedBox(
                      child: Row(
                        children: [
                          Text(
                            l10n.paywallSubscribeButton,
                            style: PaywallStyle.subscribeButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                if (onSkip != null)
                  TextButton(
                    onPressed: onSkip,
                    child: Text(
                      l10n.paywallSkip,
                      style: TutorialStyle.subTitle(),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class PaywallSuccessDialog extends StatelessWidget {
  const PaywallSuccessDialog({
    required this.controller,
    required this.l10n,
    this.timeoutDuration = const Duration(seconds: 3),
    super.key,
  });

  final ConfettiController controller;
  final L10n l10n;
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
                    l10n.paywallWelcomeTitle,
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
  final l10n = L10n.of(context);
  try {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (_) {
        return PaywallSuccessDialog(
          controller: controller,
          l10n: l10n,
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
