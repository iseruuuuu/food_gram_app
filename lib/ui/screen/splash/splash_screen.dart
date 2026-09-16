import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/auth/services/account_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/providers/friend_user_ids_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';

enum _SplashDestination {
  tab,
  registrationWelcome,
  authentication,
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  static const _splashBackgroundColor = Color(0xFFE88932);
  static const _displayDuration = Duration(milliseconds: 1200);
  static const _fadeOutDuration = Duration(milliseconds: 350);

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
    _prefetchStartupData();

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

  /// スプラッシュ表示中にタブ用データを先読みし、遷移直後の待ちを短くする。
  /// 認証確認を待たずに開始し、最低表示時間と並列で進める。
  void _prefetchStartupData() {
    _warm(ref.read(locationProvider.future));
    _warm(ref.read(blockListProvider.future));
    unawaited(CountryDetector.ensureLoaded());

    final userId = ref.read(currentUserProvider);
    if (userId == null) {
      return;
    }

    _warm(ref.read(mapRepositoryProvider.future));
    _warm(ref.read(myMapRepositoryProvider.future));
    _warm(ref.read(isSubscribeProvider.future));
    _warm(ref.read(friendUserIdsProvider.future));
    // keepAlive の Stream を購読開始し、初回イベントをメモリに載せる
    ref.read(postsStreamProvider);
    ref.read(myPostStreamProvider);
  }

  void _warm(Future<dynamic> future) {
    unawaited(
      future.then<void>(
        (_) {},
        onError: (Object _, StackTrace __) {},
      ),
    );
  }

  Future<_SplashDestination> _resolveDestination() async {
    try {
      final userId = ref.read(currentUserProvider);
      if (userId == null) {
        return _SplashDestination.authentication;
      }

      final result = await ref
          .read(accountServiceProvider)
          .ensureUserRegistered()
          .timeout(const Duration(seconds: 10));
      return result.when(
        success: (isNewUser) => isNewUser
            ? _SplashDestination.registrationWelcome
            : _SplashDestination.tab,
        failure: (_) => _SplashDestination.authentication,
      );
    } on Exception catch (_) {
      return _SplashDestination.authentication;
    }
  }

  void _navigate(_SplashDestination destination) {
    switch (destination) {
      case _SplashDestination.tab:
        context.pushReplacementNamed(RouterPath.tab);
      case _SplashDestination.registrationWelcome:
        context.pushReplacementNamed(RouterPath.registrationWelcome);
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
            child: Assets.splash.splash.image(
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
