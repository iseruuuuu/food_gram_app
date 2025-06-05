import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({
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

class AppListItemLoading extends StatelessWidget {
  const AppListItemLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Center(
        child: LoadingAnimationWidget.discreteCircle(
          color: Theme.of(context).primaryColor,
          size: 30,
        ),
      ),
    );
  }
}
