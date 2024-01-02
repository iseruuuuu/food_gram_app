import 'package:flutter/material.dart';
import 'package:food_gram_app/config/shared_preference/shared_preference.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IntroductionScreen(
          globalBackgroundColor: Colors.white,
          pages: [
            PageViewModel(
              reverse: true,
              titleWidget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.icon.icon1.image(width: 35),
                  SizedBox(width: 10),
                  Text(
                    'みんなの美味しいがここに',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10),
                  Assets.icon.icon1.image(width: 35),
                ],
              ),
              bodyWidget: Column(
                children: [
                  Text(
                    'FoodGramで、毎日の食事がもっと特別に。\n'
                    '新しい味との出会いを楽しみましょう。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 30),
                  Assets.image.tutorial1.image(
                    height: MediaQuery.sizeOf(context).height / 2,
                  ),
                ],
              ),
              // image:
            ),
            PageViewModel(
              reverse: true,
              titleWidget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.icon.icon2.image(width: 35),
                  SizedBox(width: 5),
                  Text(
                    '美味しい瞬間、シェアをしよう',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 5),
                  Assets.icon.icon1.image(width: 35),
                ],
              ),
              bodyWidget: Column(
                children: [
                  Text(
                    'FoodGramで食の世界が広がる。\n'
                    '今すぐ参加し、食の喜びを共有しよう。\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Assets.image.tutorial2.image(
                    height: MediaQuery.sizeOf(context).height / 2,
                  ),
                ],
              ),
            ),
            PageViewModel(
              titleWidget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.icon.icon3.image(width: 35),
                  SizedBox(width: 5),
                  Text(
                    '注意事項',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 5),
                  Assets.icon.icon3.image(width: 35),
                ],
              ),
              bodyWidget: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '・氏名、住所、電話番号などの個人情報を公開しないようにしましょう。また、位置情報の共有にも注意が必要です。\n\n'
                  '・不適切なコンテンツへの注意：攻撃的、不適切、または有害なコンテンツを投稿したり、共有しないようにしましょう。\n\n'
                  '・他人の作品を無断で使用したり、アプリの利用規約に反する行為は避けましょう。\n\n'
                  '・食べ物以外の投稿が確認された場合は、運営側で削除させていただく場合がございます。\n\n'
                  '・注意事項を何度も違反しているユーザーについては、運営側で削除させていただく場合がございます。\n\n'
                  '・このアプリの開発は個人で行なっているため、不完全な部分があるかもしれません。\n\n'
                  '・気になったことがあった場合は、運営側にお気軽にご連絡ください。\n\n'
                  '・最後に、いいサービスにしていくためにご協力お願いします🙇  by 開発者',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
          onDone: () async {
            final preference = Preference();
            final isFinishedTutorial = await preference.getBool(
              PreferenceKey.isFinishedTutorial,
            );
            if (!isFinishedTutorial) {
              await preference.setBool(PreferenceKey.isFinishedTutorial);
              context.pushReplacementNamed(RouterPath.splash);
            } else {
              context.pop();
            }
          },
          showBackButton: true,
          next: const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.black,
          ),
          back: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: Colors.black,
          ),
          done: const Text(
            '閉じる',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          dotsDecorator: DotsDecorator(
            size: const Size.square(10),
            activeSize: const Size(50, 10),
            activeColor: Colors.black,
            color: Colors.black26,
            spacing: const EdgeInsets.symmetric(horizontal: 3),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }
}
