import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/auth/services/account_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';

enum _SplashDestination {
  tab,
  newAccount,
  authentication,
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  static const _splashBackgroundColor = Color(0xFFF5F0E8);
  static const _displayDuration = Duration(seconds: 3);
  static const _fadeOutDuration = Duration(milliseconds: 700);

  double _opacity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _redirect();
    });
  }

  Future<void> _redirect() async {
    ref.read(currentUserProvider.notifier).update();

    final destinationFuture = _resolveDestination();

    await Future.wait<void>([
      Future<void>.delayed(_displayDuration),
      destinationFuture,
    ]);

    if (!mounted) {
      return;
    }

    setState(() {
      _opacity = 0;
    });

    await Future<void>.delayed(_fadeOutDuration);
    if (!mounted) {
      return;
    }

    _navigate(await destinationFuture);
  }

  Future<_SplashDestination> _resolveDestination() async {
    try {
      final userId = ref.read(currentUserProvider);
      if (userId == null) {
        return _SplashDestination.authentication;
      }

      final isRegistered = await ref
          .read(accountServiceProvider)
          .isUserRegistered()
          .timeout(const Duration(seconds: 10));
      return isRegistered
          ? _SplashDestination.tab
          : _SplashDestination.newAccount;
    } on Exception catch (_) {
      return _SplashDestination.authentication;
    }
  }

  void _navigate(_SplashDestination destination) {
    switch (destination) {
      case _SplashDestination.tab:
        context.pushReplacementNamed(RouterPath.tab);
      case _SplashDestination.newAccount:
        context.pushReplacementNamed(RouterPath.newAccount);
      case _SplashDestination.authentication:
        context.pushReplacementNamed(RouterPath.authentication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _splashBackgroundColor,
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: _fadeOutDuration,
        curve: Curves.easeOut,
        child: ColoredBox(
          color: _splashBackgroundColor,
          child: SizedBox.expand(
            child: Assets.splash.splashPng.image(
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
