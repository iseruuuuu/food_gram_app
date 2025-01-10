import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage<Object?> blackOut(Widget screen) {
  return CustomTransitionPage<Object?>(
    child: screen,
    transitionDuration: const Duration(seconds: 1),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final color = ColorTween(
        begin: Colors.transparent,
        end: Colors.black,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0, 0.5, curve: Curves.easeInOut),
        ),
      );
      final opacity = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.5, 1, curve: Curves.easeInOut),
        ),
      );
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return Container(
            color: color.value,
            child: Opacity(
              opacity: opacity.value,
              child: child,
            ),
          );
        },
      );
    },
  );
}

CustomTransitionPage<Object?> whiteOut(Widget screen) {
  return CustomTransitionPage<Object?>(
    child: screen,
    transitionDuration: const Duration(seconds: 1),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final colorTween = ColorTween(
        begin: Colors.transparent,
        end: Colors.white,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0, 0.5, curve: Curves.easeInOut),
        ),
      );
      final opacityTween = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.5, 1, curve: Curves.easeInOut),
        ),
      );
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          return Container(
            color: colorTween.value,
            child: Opacity(
              opacity: opacityTween.value,
              child: child,
            ),
          );
        },
      );
    },
  );
}

CustomTransitionPage<Object?> slideIn(Widget screen) {
  return CustomTransitionPage<Object?>(
    child: screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetTween = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
      );
      return SlideTransition(
        position: offsetTween,
        child: child,
      );
    },
  );
}

CustomTransitionPage<Object?> scaleUpTransition(Widget screen) {
  return CustomTransitionPage<Object?>(
    child: screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
        ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(animation),
          child: child,
        ),
      );
    },
  );
}

CustomTransitionPage<Object?> elasticTransition(Widget screen) {
  return CustomTransitionPage<Object?>(
    child: screen,
    transitionDuration: Duration(seconds: 1),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final elasticAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutExpo),
      );
      return ScaleTransition(
        scale: elasticAnimation,
        child: child,
      );
    },
  );
}

CustomTransitionPage<Object?> slideUpTransition(Widget screen) {
  return CustomTransitionPage<Object?>(
    child: screen,
    transitionDuration: const Duration(milliseconds: 400), // 遷移速度を調整
    reverseTransitionDuration: const Duration(milliseconds: 400), // 閉じるときの速度
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1), // 下から上へ
        end: Offset.zero, // 画面の中央に到達
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.ease,
        ),
      );

      final fadeAnimation = Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.ease,
        ),
      );

      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}
