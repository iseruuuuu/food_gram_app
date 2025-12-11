import 'dart:async';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/notification/notification_service.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/theme/style/tutorial_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';
import 'package:food_gram_app/ui/component/tutorial_paywall.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

class TutorialScreen extends HookConsumerWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final isAccept = useState(false);
    final isFinishedTutorial = useState(false);
    final notifier = useValueNotifier<double>(0);
    final pageController = usePageController();
    final preference = useMemoized(Preference.new);
    final controller = useMemoized(
      () => ConfettiController(duration: const Duration(seconds: 2)),
    );
    final isSubscribeAsync = ref.watch(isSubscribeProvider);
    final isSubscribed = isSubscribeAsync.valueOrNull ?? false;
    useEffect(
      () {
        Future<void> loadPreference() async {
          isAccept.value = await preference.getBool(PreferenceKey.isAccept);
          isFinishedTutorial.value = await preference.getBool(
            PreferenceKey.isFinishedTutorial,
          );
        }

        loadPreference();
        return null;
      },
      [],
    );

    void goToNextPage() {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    final isSubscribe = isSubscribed;
    const totalPages = 7;
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
                    l10n.tutorialLocationTitle,
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
                      goToNextPage();
                    },
                    title: l10n.tutorialLocationButton,
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
                        goToNextPage();
                      }
                    },
                    title: l10n.tutorialNotificationButton,
                  ),
                ],
              ),
              // 6ページ目
              if (!isSubscribe)
                TutorialPaywall(
                  onNextPage: goToNextPage,
                  confettiController: controller,
                ),
              // 7ページ目　利用規約
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
                          Assets.gif.tutorial1.image(width: 50),
                          Text(
                            l10n.tutorialThirdPageTitle,
                            style: TutorialStyle.thirdTitle(),
                          ),
                          Assets.gif.tutorial1.image(width: 50),
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
                            value: isAccept.value,
                            onChanged: (value) {
                              isAccept.value = value ?? false;
                            },
                          ),
                        ],
                      ),
                      const Gap(20),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: TutorialStyle.button(),
                          onPressed: isAccept.value
                              ? () async {
                                  if (!isFinishedTutorial.value) {
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
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    final currentPage = pageController.page?.toInt() ?? 0;
                    if (currentPage == totalPages - 1 && !isAccept.value) {
                      SnackBarHelper().openSimpleSnackBar(
                        context,
                        L10n.of(context).agreeToTheTermsOfUse,
                      );
                    } else if (currentPage < totalPages - 1) {
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
    return Stack(
      children: [
        // Base soft white gradient
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEBF4FF), // lighter blue
                  Color(0xFFF2E9FF), // lighter purple
                  Color(0xFFFFF3DA), // lighter yellow
                  Color(0xFFECFFF3), // lighter mint
                  Color(0xFFFFEAF2), // lighter pink
                ],
                stops: [0.0, 0.3, 0.55, 0.8, 1.0],
              ),
            ),
          ),
        ),
        // Translucent pastel blobs (blurred)
        const Positioned(
          top: -80,
          left: -60,
          child: _PastelBlob(
            size: 280,
            color: Color(0xFFCBE7FF), // softer blue
          ),
        ),
        const Positioned(
          top: -40,
          right: -40,
          child: _PastelBlob(
            size: 240,
            color: Color(0xFFEBDFFF), // softer purple
          ),
        ),
        const Positioned(
          bottom: -60,
          left: -40,
          child: _PastelBlob(
            size: 260,
            color: Color(0xFFD6F7E5), // softer mint
          ),
        ),
        const Positioned(
          bottom: -120,
          right: -60,
          child: _PastelBlob(
            size: 320,
            color: Color(0xFFFFE8BC), // softer yellow
          ),
        ),
        const Positioned(
          top: -70,
          left: 120,
          child: _PastelBlob(
            size: 220,
            color: Color(0xFFFFE0EA), // softer pink
          ),
        ),
        const Positioned(
          bottom: -100,
          left: 80,
          child: _PastelBlob(
            size: 240,
            color: Color(0xFFEDFFCC), // softer green-yellow
          ),
        ),
        // Content
        Positioned.fill(
          child: PageView(
            controller: controller,
            children: pages,
          ),
        ),
      ],
    );
  }
}

class _PastelBlob extends StatelessWidget {
  const _PastelBlob({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.40),
                color.withValues(alpha: 0.10),
                Colors.transparent,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
