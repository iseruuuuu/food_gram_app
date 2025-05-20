import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:lottie/lottie.dart';

class AppDataLoading extends StatelessWidget {
  const AppDataLoading({super.key});

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
