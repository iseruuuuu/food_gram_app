import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';

class AppProcessLoading extends StatelessWidget {
  const AppProcessLoading({
    required this.loading,
    required this.status,
    super.key,
  });

  final bool loading;
  final String status;

  @override
  Widget build(BuildContext context) {
    return loading
        ? AbsorbPointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: LoadingAnimationWidget.dotsTriangle(
                          color: Colors.deepPurple,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        status,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : const SizedBox();
  }
}

class AppMapLoading extends StatelessWidget {
  const AppMapLoading({
    required this.loading,
    required this.hasError,
    super.key,
  });

  final bool loading;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return loading
        ? AbsorbPointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.08),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: Theme.of(context).primaryColor,
                          size: 45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        hasError
                            ? L10n.of(context).mapLoadingError
                            : L10n.of(context).mapLoadingRestaurant,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}

class AppContentLoading extends StatelessWidget {
  const AppContentLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          Assets.lottie.loading,
          width: 150,
          height: 150,
        ),
        const Text(
          'Loading...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFDAA187),
          ),
        ),
      ],
    );
  }
}

class AppStoryLoading extends StatelessWidget {
  const AppStoryLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 100,
              height: 100,
              child: Center(
                child: LoadingAnimationWidget.discreteCircle(
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
