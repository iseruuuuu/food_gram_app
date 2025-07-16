import 'dart:async';
import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sliding_tutorial/flutter_sliding_tutorial.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/theme/style/paywall_style.dart';
import 'package:food_gram_app/core/theme/style/tutorial_style.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/screen/paywall/paywall_screen.dart';
import 'package:food_gram_app/ui/screen/setting/setting_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  bool isAccept = false;
  bool isFinishedTutorial = false;
  final ValueNotifier<double> notifier = ValueNotifier(0);
  final PageController pageController = PageController();
  final preference = Preference();
  final controller = ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    loadPreference();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<void> loadPreference() async {
    isAccept = await preference.getBool(PreferenceKey.isAccept);
    isFinishedTutorial = await preference.getBool(
      PreferenceKey.isFinishedTutorial,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = MediaQuery.sizeOf(context).width;
    final l10n = L10n.of(context);
    return Scaffold(
      body: Stack(
        children: [
          SlidingTutorial(
            controller: pageController,
            notifier: notifier,
            pageCount: 4,
            pages: [
              /// 1ページ目
              Column(
                children: [
                  const Spacer(),
                  Text(
                    l10n.tutorialFirstPageTitle,
                    style: TutorialStyle.title(),
                  ),
                  const Gap(52),
                  Assets.image.tutorial1.image(height: imageHeight),
                  const Gap(52),
                  Text(
                    l10n.tutorialFirstPageSubTitle,
                    style: TutorialStyle.subTitle(),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                ],
              ),

              /// 2ページ目
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    l10n.tutorialSecondPageTitle,
                    style: TutorialStyle.title(),
                  ),
                  const Gap(52),
                  Assets.image.tutorial2.image(height: imageHeight),
                  const Gap(52),
                  Text(
                    l10n.tutorialSecondPageSubTitle,
                    textAlign: TextAlign.center,
                    style: TutorialStyle.subTitle(),
                  ),
                  const Spacer(),
                ],
              ),

              /// 3ページ目
              DecoratedBox(
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
                    child: SafeArea(
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
                                    style: TutorialStyle.title(),
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
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.rocket_launch,
                                            color: Colors.white,
                                            size: 26,
                                          ),
                                        ),
                                        const Gap(12),
                                        Text(
                                          l10n.paywallPrice,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: TutorialStyle.button(),
                                      onPressed: () => _handlePurchase(l10n),
                                      child: FittedBox(
                                        child: Row(
                                          children: [
                                            Text(
                                              l10n.paywallSubscribeButton,
                                              style: TutorialStyle.close(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Gap(12),
                                  TextButton(
                                    onPressed: () async {
                                      await pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: Text(
                                      l10n.paywallSkip,
                                      style: TutorialStyle.subTitle(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// 4ページ目
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Gap(60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Gap(10),
                          Assets.gif.tutorial1.image(width: 60),
                          Text(
                            l10n.tutorialThirdPageTitle,
                            style: TutorialStyle.thirdTitle(),
                          ),
                          Assets.gif.tutorial1.image(width: 60),
                          const Gap(10),
                        ],
                      ),
                      const Gap(20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          l10n.tutorialThirdPageSubTitle,
                          style: TutorialStyle.thirdSubTitle(),
                        ),
                      ),
                      const Gap(30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.tutorialThirdPageButton,
                            style: TutorialStyle.accept(),
                          ),
                          const Gap(10),
                          Checkbox(
                            checkColor: Colors.white,
                            activeColor: Colors.black,
                            value: isAccept,
                            onChanged: (value) {
                              setState(() {
                                isAccept = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                      const Gap(20),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: TutorialStyle.button(),
                          onPressed: isAccept
                              ? () async {
                                  if (!isFinishedTutorial) {
                                    await preference.setBool(
                                      PreferenceKey.isFinishedTutorial,
                                    );
                                    context.go(RouterPath.splash);
                                  } else {
                                    context.pop();
                                  }
                                }
                              : null,
                          child: Text(
                            l10n.tutorialThirdPageClose,
                            style: TutorialStyle.close(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    final currentPage = pageController.page?.toInt() ?? 0;
                    if (currentPage == 3 && !isAccept) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            L10n.of(context).agreeToTheTermsOfUse,
                          ),
                        ),
                      );
                    } else if (currentPage < 3) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                    // 最後のページ（4枚目）では何もしない
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.amber[700], size: 26),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(L10n l10n) async {
    try {
      final result = await ref
          .read(
            settingViewModelProvider().notifier,
          )
          .purchase();
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
            },
          ).timeout(
            const Duration(seconds: 3),
          );
        } on TimeoutException {
          if (context.mounted) {
            context.pop();
            await pageController.nextPage(
              duration: const Duration(
                milliseconds: 500,
              ),
              curve: Curves.easeInOut,
            );
          }
        }
      } else {
        if (context.mounted) {
          await pageController.nextPage(
            duration: const Duration(
              milliseconds: 500,
            ),
            curve: Curves.easeInOut,
          );
        }
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.purchaseError}: $e'),
          ),
        );
        await pageController.nextPage(
          duration: const Duration(
            milliseconds: 500,
          ),
          curve: Curves.easeInOut,
        );
      }
    }
  }
}

class SlidingTutorial extends StatelessWidget {
  const SlidingTutorial({
    required this.controller,
    required this.notifier,
    required this.pageCount,
    required this.pages,
    super.key,
  });

  final PageController controller;
  final ValueNotifier<double> notifier;
  final int pageCount;
  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return AnimatedBackgroundColor(
      pageController: controller,
      pageCount: pageCount,
      colors: const [Color(0xFFFFF3B0)],
      child: PageView(
        controller: controller,
        children: pages,
      ),
    );
  }
}
