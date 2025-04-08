import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/auth/services/account_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    redirect(context, ref);
    super.initState();
  }

  Future<void> redirect(BuildContext context, WidgetRef ref) async {
    ref.read(currentUserProvider.notifier).update();
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
      body: Center(
        child: Assets.splash.splashGif.image(
          fit: BoxFit.cover,
          width: MediaQuery.sizeOf(context).width / 2,
          height: MediaQuery.sizeOf(context).width / 2,
        ),
      ),
    );
  }
}
