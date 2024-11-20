import 'package:flutter/material.dart';
import 'package:flutter_sliding_tutorial/flutter_sliding_tutorial.dart';
import 'package:food_gram_app/core/config/shared_preference/shared_preference.dart';
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
    final imageHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Stack(
        children: [
          SlidingTutorial(
            controller: pageController,
            notifier: notifier,
            pageCount: 3,
            pages: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  const Text(
                    '美味しい瞬間、シェアしよう',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(10),
                  Text(
                    'FoodGramで、毎日の食事がもっと特別に\n'
                    '新しい味との出会いを楽しもう',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Gap(20),
                  Assets.image.tutorial1.image(height: imageHeight / 1.5),
                  Spacer(),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  const Text(
                    'みんなで作る、特別なフードマップ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Gap(10),
                  const Text(
                    'このアプリだけのマップ作りをしよう\n'
                    'あなたの投稿でマップが進化していく',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  Gap(20),
                  Assets.image.tutorial2.image(height: imageHeight / 1.5),
                  Spacer(),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Gap(30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Gap(10),
                      Assets.gif.tutorial1.image(width: 60),
                      const Text(
                        '利用規約',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Assets.gif.tutorial1.image(width: 60),
                      Gap(10),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      '・氏名、住所、電話番号などの個人情報や位置情報の公開には注意しましょう。\n\n'
                      '・攻撃的、不適切、または有害なコンテンツの投稿を避け、他人の作品を無断で使用しないようにしましょう。\n\n'
                      '・食べ物以外の投稿は削除させていただく場合があります。\n\n'
                      '・違反が繰り返されるユーザーや不快なコンテンツは運営側で削除します。\n\n'
                      '・アプリには不完全な部分があるかもしれませんので、ご理解ください。\n\n'
                      '・みなさんと一緒にこのアプリをより良くしていけることを楽しみにしています。\n\n'
                      '・サービス向上のため、ご協力お願いします🙇 by 開発者',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '利用規約に同意する',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Gap(10),
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
                  Spacer(),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isAccept
                          ? () async {
                              if (!isFinishedTutorial) {
                                await preference
                                    .setBool(PreferenceKey.isFinishedTutorial);
                                context.go(RouterPath.splash);
                              } else {
                                context.pop();
                              }
                            }
                          : null,
                      child: const Text(
                        '閉じる',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    if (pageController.page?.toInt() == 2 && !isAccept) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(L10n.of(context).agreeToTheTermsOfUse),
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
      colors: const [
        Color(0xFFFFFDD0),
        Color(0xFFFFFCC0),
        Color(0xFFFFFBAC),
      ],
      child: PageView(
        controller: controller,
        children: pages,
      ),
    );
  }
}
