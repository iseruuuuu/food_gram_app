import 'dart:async';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/notification/notification_service.dart';
import 'package:food_gram_app/core/theme/style/tutorial_style.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';
import 'package:food_gram_app/ui/component/paywall_widget.dart';
import 'package:food_gram_app/ui/screen/setting/setting_view_model.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

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
            pageCount: totalPages,
            pages: [
              // 1ページ目
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    Assets.lottie.tutorial1,
                    width: 250,
                    height: 250,
                  ),
                  const Gap(24),
                  Text(
                    l10n.tutorialFirstPageTitle,
                    style: TutorialStyle.title(),
                  ),
                  const Gap(12),
                  Text(
                    l10n.tutorialFirstPageSubTitle,
                    style: TutorialStyle.subTitle(),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(120),
                ],
              ),
              // 2ページ目
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    Assets.lottie.tutorial2,
                    width: 250,
                    height: 250,
                  ),
                  const Gap(24),
                  Text(
                    l10n.tutorialDiscoverTitle,
                    style: TutorialStyle.title(),
                  ),
                  const Gap(12),
                  Text(
                    l10n.tutorialDiscoverSubTitle,
                    style: TutorialStyle.subTitle(),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(120),
                ],
              ),
              // 3ページ目
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    Assets.lottie.tutorial3,
                    width: 400,
                    height: 150,
                  ),
                  const Gap(24),
                  Text(
                    l10n.tutorialSecondPageTitle,
                    style: TutorialStyle.title(),
                  ),
                  const Gap(12),
                  Text(
                    l10n.tutorialSecondPageSubTitle,
                    style: TutorialStyle.subTitle(),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(24),
                ],
              ),
              // 4ページ目
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    Assets.lottie.permission,
                    width: 400,
                    height: 180,
                  ),
                  const Gap(56),
                  Text(
                    l10n.appRequestTitle,
                    style: TutorialStyle.title(),
                  ),
                  const Gap(12),
                  Text(
                    l10n.appRequestReason,
                    style: TutorialStyle.subTitle(),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(36),
                  AppElevatedButton(
                    onPressed: () async {
                      final permission = await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied) {
                        await Geolocator.requestPermission();
                      }
                      _goToNextPage();
                    },
                    title: l10n.appRequestOpenSetting,
                  ),
                ],
              ),
              // 5ページ目
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    Assets.lottie.notification,
                    width: 400,
                    height: 180,
                  ),
                  const Gap(48),
                  Text(
                    l10n.tutorialDiscoverTitle,
                    style: TutorialStyle.title(),
                  ),
                  const Gap(12),
                  Text(
                    l10n.tutorialDiscoverSubTitle,
                    style: TutorialStyle.subTitle(),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(36),
                  AppElevatedButton(
                    onPressed: () async {
                      final notificationService = NotificationService();
                      await notificationService.initialize();
                      final hasPermission =
                          await notificationService.checkPermissions();
                      if (!hasPermission) {
                        await openAppSettings();
                      } else {
                        _goToNextPage();
                      }
                    },
                    title: l10n.tutorialNotificationButton,
                  ),
                ],
              ),
              // 6ページ目
              PaywallBackground(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PaywallContent(
                          onPurchase: _handlePurchase,
                          onSkip: () async {
                            await pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          showSkipButton: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 7ページ目
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

  Future<void> _handlePurchase() async {
    final l10n = L10n.of(context);
    try {
      final result =
          await ref.read(settingViewModelProvider().notifier).purchase();
      if (!context.mounted) {
        return;
      }
      if (result) {
        controller.play();
        await showPaywallSuccessDialog(
          context: context,
          controller: controller,
        );
        _goToNextPage();
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.purchaseError}: $e'),
          ),
        );
        _goToNextPage();
      }
    }
  }

  void _goToNextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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
