import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/mixin/account_exist_mixin.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with AccountExistMixin {
  @override
  void initState() {
    redirect(context);
    super.initState();
  }

  Future<void> redirect(BuildContext context) async {
    await Future.delayed(Duration.zero);
    if (!await doesAccountExist()) {
      context.pushReplacementNamed(RouterPath.newAccount);
    } else {
      context.pushReplacementNamed(RouterPath.tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      body: Center(
        child: Image(
          image: AssetImage('assets/loading/loading.gif'),
          fit: BoxFit.cover,
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}
