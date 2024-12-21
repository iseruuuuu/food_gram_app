import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_header.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:food_gram_app/ui/screen/setting/setting_view_model.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
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
              filter: ImageFilter.blur(),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                      iconSize: 28,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, -4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, 4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(child: AnimatedGradientBackground()),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    AppProfileImage(
                                      imagePath: 'assets/icon/icon3.png',
                                      radius: 42,
                                    ),
                                    Spacer(),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '100',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          l10n.profilePostCount,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gap(30),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '100',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          l10n.profilePointCount,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Text(
                                  'Food Gram',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '@foodgram',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Gap(4),
                                Text(
                                  'I am FoodGram member ship 😀',
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.sizeOf(context).width - 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Gap(18),
                        Text(
                          'FoodGram \n'
                          'SPECIAL MEMBERSHIP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '食を愛する人のための特別特典',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        Gap(16),
                        Text(
                          '🎉 特典紹介 🎉',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        Gap(16),
                        ListTile(
                          title: Text(
                            'プロフィールがプラチナ仕様に ✨️',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(Icons.check_circle_outline),
                        ),
                        ListTile(
                          title: Text(
                            'アイコンを自由に設定できる⚒️',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(Icons.check_circle_outline),
                        ),
                        ListTile(
                          title: Text(
                            '広告が一切でない️🙅',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          trailing: Icon(Icons.check_circle_outline),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.image.paywall2.image(width: 40),
                                Spacer(),
                                Center(
                                  child: Text(
                                    'さらなる機能を続々追加予定',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Assets.image.paywall2.image(width: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppLoading(
            loading: loading,
            status: 'Loading...',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 100,
        color: !loading ? Colors.white : Colors.transparent,
        child: !loading
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 10,
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await ref
                        .read(settingViewModelProvider().notifier)
                        .purchase()
                        .then((result) async {
                      if (result) {
                        controller.play();
                        try {
                          await showDialog(
                            context: context,
                            barrierColor: Colors.black87,
                            barrierDismissible: false,
                            builder: (_) {
                              return AlertDialog(
                                backgroundColor: Colors.transparent,
                                title: SizedBox(
                                  height: 600,
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
                                      Spacer(),
                                      Container(
                                        color: Colors.transparent,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 10,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Welcome to \n '
                                              'FoodGram Members!',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Gap(30),
                                            Assets.image.present.image(
                                              width: 200,
                                              height: 200,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ).timeout(Duration(seconds: 5));
                        } on TimeoutException {
                          context.pop();
                        }
                        context.pop();
                      }
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Subscribe Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '￥300/month',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox.shrink(),
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

  for (double step = 0; step < fullAngle; step += degreesPerStep) {
    path
      ..lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step))
      ..lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
  }
  path.close();
  return path;
}
