import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/notification/notification_initializer.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/theme/style/tutorial_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/helpers/url_launch_helper.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';

class TutorialScreen extends HookConsumerWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isAcceptTerms = useState(false);
    final isAcceptPrivacy = useState(false);
    final isFinishedTutorial = useState(false);
    final notifier = useValueNotifier<double>(0);
    final pageController = usePageController();
    final currentPageIndex = useState(0);
    useListenable(currentPageIndex);
    final preference = useMemoized(Preference.new);
    useEffect(
      () {
        Future<void> loadPreference() async {
          final isAccepted = await preference.getBool(PreferenceKey.isAccept);
          isAcceptTerms.value = isAccepted;
          isAcceptPrivacy.value = isAccepted;
          isFinishedTutorial.value = await preference.getBool(
            PreferenceKey.isFinishedTutorial,
          );
          if (!isFinishedTutorial.value) {
            ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
                  name: AnalyticsEvent.tutorialStart,
                );
          }
        }

        loadPreference();
        return null;
      },
      [],
    );
    useEffect(
      () {
        void updatePageIndex() {
          final page = pageController.page;
          if (page != null) {
            currentPageIndex.value = page.round();
          }
        }

        pageController.addListener(updatePageIndex);
        WidgetsBinding.instance.addPostFrameCallback((_) => updatePageIndex());
        return () => pageController.removeListener(updatePageIndex);
      },
      [pageController],
    );

    const totalPages = 7;
    const locationPageIndex = 4;
    const notificationPageIndex = 5;
    const welcomePageIndex = 6;
    final currentPage = currentPageIndex.value;
    final showStandardNextButton = currentPage <= 3;
    final showWelcomeButton = currentPage == welcomePageIndex;
    final canStartWelcome = isAcceptTerms.value && isAcceptPrivacy.value;

    Future<void> goToNextPage() async {
      if (!context.mounted || !pageController.hasClients) {
        return;
      }
      await pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    Future<void> handleLocationPermission() async {
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        }
      } on Exception catch (_) {
        // 許可に失敗してもチュートリアルは続行する
      }
      if (!context.mounted) {
        return;
      }
      await goToNextPage();
    }

    Future<void> handleNotificationPermission() async {
      try {
        await requestTutorialNotificationPermission().timeout(
          const Duration(seconds: 30),
        );
      } on Exception catch (_) {
        // 許可に失敗してもチュートリアルは続行する
      }
      unawaited(() async {
        try {
          await initializeNotifications().timeout(
            const Duration(seconds: 15),
          );
        } on Exception catch (_) {
          // バックグラウンド初期化失敗はチュートリアル進行を止めない
        }
      }());
      if (!context.mounted) {
        return;
      }
      await goToNextPage();
    }

    Future<void> handleWelcomeStart() async {
      if (!canStartWelcome) {
        SnackBarHelper().openSimpleSnackBar(
          context,
          t.tutorial.agreeToTermsAndPrivacy,
        );
        return;
      }

      if (!isFinishedTutorial.value) {
        await preference.setBool(PreferenceKey.isAccept);
        await preference.setBool(PreferenceKey.isFinishedTutorial);
        unawaited(
          ref.read(firebaseAnalyticsServiceProvider).logEvent(
                name: AnalyticsEvent.tutorialComplete,
              ),
        );
        if (context.mounted) {
          context.go(RouterPath.splash);
        }
      } else if (context.mounted) {
        context.pop();
      }
    }

    Future<void> handleNextPressed() async {
      if (currentPageIndex.value < totalPages - 1) {
        await goToNextPage();
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          SlidingTutorial(
            controller: pageController,
            notifier: notifier,
            pageCount: totalPages,
            pages: [
              // 1ページ目 コンセプト
              _TutorialContentPage(
                lottie: Assets.lottie.tutorial1,
                title: t.tutorial.firstPageTitle,
                subtitle: t.tutorial.firstPageSubTitle1,
              ),
              // 2ページ目 探索
              _TutorialContentPage(
                lottie: Assets.lottie.tutorial2,
                title: t.tutorial.discoverTitle,
                subtitle: t.tutorial.discoverSubTitle1,
              ),
              // 3ページ目 世界マップ
              _TutorialContentPage(
                lottie: Assets.lottie.tutorial3,
                lottieWidth: 400,
                title: t.tutorial.secondPageTitle,
                subtitle: t.tutorial.secondPageSubTitle1,
              ),
              // 4ページ目 投稿しよう
              _TutorialContentPage(
                lottie: Assets.lottie.tutorial4,
                title: t.tutorial.postPageTitle,
                subtitle: t.tutorial.postPageMain,
              ),
              // 5ページ目(位置情報の許可)
              _TutorialContentPage(
                lottie: Assets.lottie.location,
                lottieWidth: 400,
                title: t.tutorial.locationTitle,
                subtitle: t.tutorial.locationSubTitle,
              ),
              // 6ページ目（通知の許可）
              _TutorialContentPage(
                lottie: Assets.lottie.notification,
                lottieWidth: 400,
                title: t.tutorial.notificationTitle,
                subtitle: t.tutorial.notificationSubTitle,
              ),
              // 7ページ目 アプリ開始（モチベーション）
              _TutorialContentPage(
                lottie: Assets.lottie.welcome,
                lottieWidth: 400,
                title: t.tutorial.welcomePageTitle,
                subtitle: t.tutorial.welcomePageBody,
                bottomContent: _TutorialAgreementSection(
                  agreeTermsLabel: t.tutorial.agreeToTerms,
                  agreePrivacyLabel: t.tutorial.agreeToPrivacy,
                  isTermsAccepted: isAcceptTerms.value,
                  isPrivacyAccepted: isAcceptPrivacy.value,
                  onTermsChanged: (value) {
                    isAcceptTerms.value = value ?? false;
                  },
                  onPrivacyChanged: (value) {
                    isAcceptPrivacy.value = value ?? false;
                  },
                  onOpenTerms: () {
                    LaunchUrlHelper().open(URL.termsOfUse(context));
                  },
                  onOpenPrivacy: () {
                    LaunchUrlHelper().open(URL.privacyPolicy(context));
                  },
                ),
                bottomPadding: 180,
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showStandardNextButton)
                      AppElevatedButton(
                        onPressed: handleNextPressed,
                        title: t.tutorial.nextButton,
                        backgroundColor: AppTheme.primaryBlue,
                        horizontalInset: 48,
                      )
                    else if (showWelcomeButton)
                      Opacity(
                        opacity: canStartWelcome ? 1 : 0.5,
                        child: AppElevatedButton(
                          onPressed: handleWelcomeStart,
                          title: t.tutorial.welcomePageButton,
                          backgroundColor: AppTheme.primaryBlue,
                          horizontalInset: 48,
                        ),
                      )
                    else if (currentPage == locationPageIndex)
                      AppElevatedButton(
                        onPressed: handleLocationPermission,
                        title: t.tutorial.locationButton,
                        backgroundColor: AppTheme.primaryBlue,
                        horizontalInset: 48,
                      )
                    else if (currentPage == notificationPageIndex)
                      AppElevatedButton(
                        onPressed: handleNotificationPermission,
                        title: t.tutorial.notificationButton,
                        backgroundColor: AppTheme.primaryBlue,
                        horizontalInset: 48,
                      ),
                    if (showStandardNextButton ||
                        showWelcomeButton ||
                        currentPage == locationPageIndex ||
                        currentPage == notificationPageIndex)
                      const Gap(16),
                    _TutorialPageIndicator(
                      count: totalPages,
                      currentIndex: currentPageIndex.value,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        // Base background（ライト: パステルグラデーション / ダーク: surface）
        Positioned.fill(
          child: DecoratedBox(
            decoration: isDark
                ? BoxDecoration(
                    color: colorScheme.surface,
                  )
                : const BoxDecoration(
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
        // Translucent pastel blobs (blurred) - ライトモードのみ
        if (!isDark) ...[
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
        ],
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

class _TutorialContentPage extends StatelessWidget {
  const _TutorialContentPage({
    required this.lottie,
    required this.title,
    required this.subtitle,
    this.lottieWidth = 250,
    this.bottomContent,
    this.bottomPadding = 120,
  });

  final String lottie;
  final String title;
  final String subtitle;
  final double lottieWidth;
  final Widget? bottomContent;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final lottieHeight =
                  (constraints.maxHeight * 0.38).clamp(120.0, 250.0);
              final lottieDisplayWidth = (lottieWidth * (lottieHeight / 250))
                  .clamp(120.0, lottieWidth);

              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        lottie,
                        width: lottieDisplayWidth,
                        height: lottieHeight,
                        fit: BoxFit.contain,
                      ),
                      const Gap(24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: FittedBox(
                          child: Text(
                            title,
                            style: TutorialStyle.title(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const Gap(18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: FittedBox(
                          child: Text(
                            subtitle,
                            style: TutorialStyle.subTitle(context),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      if (bottomContent != null) ...[
                        const Gap(24),
                        bottomContent!,
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: bottomPadding),
      ],
    );
  }
}

class _TutorialAgreementSection extends StatelessWidget {
  const _TutorialAgreementSection({
    required this.agreeTermsLabel,
    required this.agreePrivacyLabel,
    required this.isTermsAccepted,
    required this.isPrivacyAccepted,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  final String agreeTermsLabel;
  final String agreePrivacyLabel;
  final bool isTermsAccepted;
  final bool isPrivacyAccepted;
  final ValueChanged<bool?> onTermsChanged;
  final ValueChanged<bool?> onPrivacyChanged;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            _TutorialAgreementRow(
              label: agreeTermsLabel,
              value: isTermsAccepted,
              onChanged: onTermsChanged,
              onOpen: onOpenTerms,
            ),
            Divider(
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.15),
            ),
            _TutorialAgreementRow(
              label: agreePrivacyLabel,
              value: isPrivacyAccepted,
              onChanged: onPrivacyChanged,
              onOpen: onOpenPrivacy,
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialAgreementRow extends StatelessWidget {
  const _TutorialAgreementRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onOpen,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryBlue,
            checkColor: Colors.white,
            side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(!value),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onOpen,
            icon: const Icon(
              Icons.chevron_right,
              color: AppTheme.primaryBlue,
              size: 22,
            ),
            tooltip: label,
          ),
        ],
      ),
    );
  }
}

class _TutorialPageIndicator extends StatelessWidget {
  const _TutorialPageIndicator({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 10 : 7,
            height: isActive ? 10 : 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? color : color.withValues(alpha: 0.3),
            ),
          ),
        );
      }),
    );
  }
}
