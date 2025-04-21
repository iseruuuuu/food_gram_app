import 'package:flutter/material.dart';
import 'package:flutter_sliding_tutorial/flutter_sliding_tutorial.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/theme/style/tutorial_style.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  bool isAccept = false;
  bool isFinishedTutorial = false;
  final ValueNotifier<double> notifier = ValueNotifier(0);
  final PageController pageController = PageController();
  final preference = Preference();

  @override
  void initState() {
    loadPreference();
    super.initState();
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
            pageCount: 3,
            pages: [
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
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Gap(30),
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
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        l10n.tutorialThirdPageSubTitle,
                        style: TutorialStyle.thirdSubTitle(),
                      ),
                    ),
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
                    const SizedBox(height: 20),
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
                    if (pageController.page?.toInt() == 2 && !isAccept) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            L10n.of(context).agreeToTheTermsOfUse,
                          ),
                        ),
                      );
                    } else {
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
