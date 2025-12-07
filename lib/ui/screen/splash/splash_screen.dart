import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/auth/services/account_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';
import 'package:motor/motor.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  double titleProgress = 0;
  bool showBranding = true;

  @override
  void initState() {
    redirect(context, ref);
    // 1フレーム後に 0→1 へ更新して文字を順次表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        titleProgress = 1.0;
      });
    });
    super.initState();
  }

  Future<void> redirect(BuildContext context, WidgetRef ref) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    ref.read(currentUserProvider.notifier).update();
    setState(() {
      showBranding = false;
    });
    if (await ref.read(accountServiceProvider).isUserRegistered()) {
      context.pushReplacementNamed(RouterPath.tab);
    } else {
      context.pushReplacementNamed(RouterPath.newAccount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Center(
            child: Assets.splash.splashGif.image(
              fit: BoxFit.cover,
              width: MediaQuery.sizeOf(context).width / 2,
              height: MediaQuery.sizeOf(context).width / 2,
            ),
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: showBranding ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: ColoredBox(
                color: Colors.white,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    // アイコンは左に固定
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child:
                            Assets.image.appIcon.image(width: 90, height: 90),
                      ),
                    ),
                    // テキストのみアニメーションし、アイコンの右隣に並べる
                    SingleMotionBuilder(
                      // 少しゆっくり文字を出す（約1.8秒）
                      motion: const Motion.curved(
                        Duration(milliseconds: 1800),
                        Curves.easeOutCubic,
                      ),
                      value: titleProgress,
                      from: 0,
                      builder: (context, t, child) {
                        const double leftPadding = 24;
                        const double iconWidth = 80;
                        const double gap = 12;
                        final scale = 0.95 + 0.05 * t;
                        final letterSpacing = -10.0 + 10.0 * t;
                        const fullText = 'FoodGram';
                        const len = fullText.length;
                        final count =
                            (len * t).ceil().clamp(1, len); // F → 徐々に増える
                        final display = fullText.substring(0, count);
                        final style = TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: letterSpacing,
                        );
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: leftPadding + iconWidth + gap,
                            ),
                            child: Transform.scale(
                              scale: scale,
                              child: Text(display, style: style),
                            ),
                          ),
                        );
                      },
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
