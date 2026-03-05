import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/notification/notification_initializer.dart';
import 'package:food_gram_app/core/theme/style/tutorial_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
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
    final isAccept = useState(false);
    final isFinishedTutorial = useState(false);
    final notifier = useValueNotifier<double>(0);
    final pageController = usePageController();
    final currentPageIndex = useState(0);
    useListenable(currentPageIndex);
    final preference = useMemoized(Preference.new);
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

    void goToNextPage() {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    const totalPages = 8;
    return Scaffold(
      body: Stack(
        children: [
          SlidingTutorial(
            controller: pageController,
            notifier: notifier,
            pageCount: totalPages,
            pages: [
              // 1ページ目 コンセプト
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Lottie.asset(
                    Assets.lottie.tutorial1,
                    width: 250,
                    height: 250,
                  ),
                  const Gap(24),
                  Text(
                    t.tutorial.firstPageTitle,
                    style: TutorialStyle.title(context),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 8,
                    children: [
                      _FeaturePill(
                        icon: '📸',
                        label: t.tutorial.pillPost,
                      ),
                      const Gap(4),
                      _FeaturePill(
                        icon: '🌎',
                        label: t.tutorial.pillShareWorld,
                      ),
                      const Gap(4),
                      _FeaturePill(
                        icon: '📍',
                        label: t.tutorial.pillMapRecord,
                      ),
                    ],
                  ),
                  const Gap(18),
                  Text(
                    t.tutorial.firstPageSubTitle1,
                    style: TutorialStyle.subTitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(12),
                  Text(
                    t.tutorial.firstPageSubTitle2,
                    style: TutorialStyle.subTitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 2),
                ],
              ),
              // 2ページ目 探索
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Lottie.asset(
                    Assets.lottie.tutorial2,
                    width: 250,
                    height: 250,
                  ),
                  const Gap(40),
                  Text(
                    t.tutorial.discoverTitle,
                    style: TutorialStyle.title(context),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeaturePill(
                        icon: '🍣',
                        label: t.tutorial.pillSushi,
                      ),
                      const Gap(8),
                      _FeaturePill(
                        icon: '🍔',
                        label: t.tutorial.pillBurger,
                      ),
                      const Gap(8),
                      _FeaturePill(
                        icon: '🍜',
                        label: t.tutorial.pillRamen,
                      ),
                    ],
                  ),
                  const Gap(18),
                  Text(
                    t.tutorial.discoverSubTitle1,
                    style: TutorialStyle.subTitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(12),
                  Text(
                    t.tutorial.discoverSubTitle2,
                    style: TutorialStyle.subTitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                ],
              ),
              // 3ページ目 世界マップ
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Lottie.asset(
                    Assets.lottie.tutorial3,
                    width: 400,
                    height: 250,
                  ),
                  const Gap(32),
                  Text(
                    t.tutorial.secondPageTitle,
                    style: TutorialStyle.title(context),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 8,
                    children: [
                      _FeaturePill(
                        icon: '🇯🇵',
                        label: t.tutorial.pillJapan,
                      ),
                      const Gap(8),
                      _FeaturePill(
                        icon: '🇺🇸',
                        label: t.tutorial.pillUSA,
                      ),
                      const Gap(8),
                      _FeaturePill(
                        icon: '🇩🇪',
                        label: t.tutorial.pillGermany,
                      ),
                      const Gap(8),
                      _FeaturePill(
                        icon: '🇹🇼',
                        label: t.tutorial.pillTaiwan,
                      ),
                      const Gap(8),
                      _FeaturePill(
                        icon: '',
                        label: t.tutorial.pillMoreCountries,
                      ),
                    ],
                  ),
                  const Gap(18),
                  Text(
                    t.tutorial.secondPageSubTitle1,
                    style: TutorialStyle.subTitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(12),
                  Text(
                    t.tutorial.secondPageSubTitle2,
                    style: TutorialStyle.subTitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 2),
                ],
              ),
              // 4ページ目 投稿しよう
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Lottie.asset(
                    Assets.lottie.tutorial4,
                    width: 250,
                    height: 250,
                  ),
                  const Gap(20),
                  Text(
                    t.tutorial.postPageTitle,
                    style: TutorialStyle.title(context),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeaturePill(
                        icon: '☕',
                        label: t.tutorial.pillCafe,
                      ),
                      const Gap(8),
                      _FeaturePill(
                        icon: '🍜',
                        label: t.tutorial.pillRamen,
                      ),
                      const Gap(8),
                      _FeaturePill(
                        icon: '🍱',
                        label: t.tutorial.pillBento,
                      ),
                      const Gap(8),
                      _FeaturePill(
                        icon: '🍰',
                        label: t.tutorial.pillCake,
                      ),
                    ],
                  ),
                  const Gap(18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      t.tutorial.postPageMain,
                      style: TutorialStyle.subTitle(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    t.tutorial.postPagePastPhotoOk,
                    style: TutorialStyle.subTitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(18),
                  const Spacer(flex: 2),
                ],
              ),
              // 5ページ目(位置情報の許可)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Lottie.asset(
                    Assets.lottie.location,
                    width: 400,
                    height: 250,
                  ),
                  const Gap(24),
                  Text(
                    t.tutorial.locationTitle,
                    style: TutorialStyle.title(context),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      t.tutorial.locationSubTitle,
                      style: TutorialStyle.subTitle(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Gap(18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeaturePill(
                        icon: '📍',
                        label: t.tutorial.pillNearbyPosts,
                      ),
                      const Gap(4),
                      _FeaturePill(
                        icon: '🔥',
                        label: t.tutorial.pillPopularSpots,
                      ),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeaturePill(
                        icon: '🗺',
                        label: t.tutorial.pillMapDisplay,
                      ),
                      const Gap(4),
                      _FeaturePill(
                        icon: '🍜',
                        label: t.tutorial.pillDiscoverWorldFood,
                      ),
                    ],
                  ),
                  const Gap(32),
                  AppElevatedButton(
                    onPressed: () async {
                      final permission = await Geolocator.checkPermission();
                      if (permission == LocationPermission.denied) {
                        await Geolocator.requestPermission();
                      }
                      goToNextPage();
                    },
                    title: t.maybeNotFoodDialog.confirm,
                  ),
                  const Spacer(),
                ],
              ),
              // 6ページ目（通知の許可）
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Lottie.asset(
                    Assets.lottie.notification,
                    width: 400,
                    height: 250,
                  ),
                  const Gap(40),
                  Text(
                    t.tutorial.notificationTitle,
                    style: TutorialStyle.title(context),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      t.tutorial.notificationSubTitle,
                      style: TutorialStyle.subTitle(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Gap(12),
                  _FeaturePill(
                    icon: '👍️ ',
                    label: t.tutorial.pillReactions,
                  ),
                  const Gap(12),
                  _FeaturePill(
                    icon: '🍱 ',
                    label: t.tutorial.pillMealReminder,
                  ),
                  const Gap(36),
                  AppElevatedButton(
                    onPressed: () async {
                      await initializeNotifications();
                      goToNextPage();
                    },
                    title: t.maybeNotFoodDialog.confirm,
                  ),
                  const Spacer(),
                ],
              ),
              // 8ページ目 アプリ開始（モチベーション）
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    t.tutorial.welcomePageTitle,
                    style: TutorialStyle.title(context),
                  ),
                  Lottie.asset(
                    Assets.lottie.welcome,
                    width: 400,
                    height: 250,
                  ),
                  const Gap(12),
                  Text(
                    t.tutorial.welcomePageSubTitle,
                    style: TutorialStyle.subTitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(12),
                  Text(
                    t.tutorial.welcomePageBody,
                    style: TutorialStyle.subTitle(context),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(32),
                  AppElevatedButton(
                    onPressed: () async {
                      goToNextPage();
                    },
                    title: t.maybeNotFoodDialog.confirm,
                  ),
                  const Spacer(),
                ],
              ),
              // 最終ページ 利用規約
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
                            t.tutorial.thirdPageTitle,
                            style: TutorialStyle.thirdTitle(context),
                          ),
                          Assets.gif.tutorial1.image(width: 50),
                          const Gap(10),
                        ],
                      ),
                      const Gap(20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          t.tutorial.thirdPageSubTitle,
                          style: TutorialStyle.thirdSubTitle(context),
                        ),
                      ),
                      const Gap(30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            t.tutorial.thirdPageButton,
                            style: TutorialStyle.accept(context),
                          ),
                          const Gap(10),
                          Checkbox(
                            checkColor: Theme.of(context).colorScheme.onPrimary,
                            activeColor: Theme.of(context).colorScheme.primary,
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
                          style: TutorialStyle.button(context),
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
                            t.tutorial.thirdPageClose,
                            style: TutorialStyle.close(context),
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
              // 4ページ目（位置情報）・5ページ目（通知）の許可説明では矢印を表示しない
              if (currentPageIndex.value != 4 && currentPageIndex.value != 5)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () async {
                      final currentPage = pageController.page?.toInt() ?? 0;

                      if (currentPage == totalPages - 1 && !isAccept.value) {
                        SnackBarHelper().openSimpleSnackBar(
                          context,
                          Translations.of(context)
                              .tutorial
                              .agreeToTheTermsOfUse,
                        );
                      } else if (currentPage < totalPages - 1) {
                        await pageController.nextPage(
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

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.icon,
    required this.label,
  });

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
