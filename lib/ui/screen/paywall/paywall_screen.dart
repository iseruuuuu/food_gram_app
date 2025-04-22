import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/theme/style/paywall_style.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/screen/setting/setting_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final loading = ref.watch(loadingProvider);
    final controller = ConfettiController(duration: const Duration(seconds: 2));

    return Scaffold(
      body: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.image.paywallBackground.path),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    onPressed: context.pop,
                    iconSize: 28,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    l10n.paywallTitle,
                    style: PaywallStyle.title(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
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
                              _buildFeatureItem(
                                icon: Icons.emoji_events,
                                title: l10n.paywallTrophyTitle,
                                description: l10n.paywallTrophyDesc,
                              ),
                              _buildFeatureItem(
                                icon: Icons.label,
                                title: l10n.paywallTagTitle,
                                description: l10n.paywallTagDesc,
                              ),
                              _buildFeatureItem(
                                icon: Icons.account_circle,
                                title: l10n.paywallIconTitle,
                                description: l10n.paywallIconDesc,
                              ),
                              _buildFeatureItem(
                                icon: Icons.block,
                                title: l10n.paywallAdTitle,
                                description: l10n.paywallAdDesc,
                              ),
                              Container(
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
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.rocket_launch,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const Gap(12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppLoading(
            loading: loading,
            status: 'Loading...',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          style: PaywallStyle.button(),
          onPressed: () async {
            await ref
                .read(settingViewModelProvider().notifier)
                .purchase()
                .then((result) async {
              if (result) {
                controller.play();
                try {
                  await showDialog<void>(
                    context: context,
                    barrierColor: Colors.black87,
                    barrierDismissible: false,
                    builder: (_) {
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
                                    blastDirectionality:
                                        BlastDirectionality.explosive,
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
                    },
                  ).timeout(const Duration(seconds: 5));
                } on TimeoutException {
                  context.pop();
                }
                context.pop(true);
              }
            });
          },
          child: FittedBox(
            child: Column(
              children: [
                Text(
                  l10n.paywallSubscribeButton,
                  style: PaywallStyle.subscribeButton(),
                ),
                const Gap(2),
                Text(
                  '${l10n.paywallPrice} (${l10n.paywallCancelNote})',
                  style: PaywallStyle.price(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.amber[700], size: 24),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: PaywallStyle.contentsTitle()),
                Text(description, style: PaywallStyle.contentsDescription()),
              ],
            ),
          ),
        ],
      ),
    );
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
