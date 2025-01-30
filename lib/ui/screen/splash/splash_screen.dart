import 'package:flutter/material.dart';
import 'package:food_gram_app/core/data/supabase/auth/account_service.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    redirect(context);
    super.initState();
  }

  Future<void> redirect(BuildContext context) async {
    await Future.delayed(Duration());
    if (await AccountService.isUserRegistered()) {
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
