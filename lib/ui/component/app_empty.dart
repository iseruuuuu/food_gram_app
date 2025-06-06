import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';

class AppEmpty extends StatelessWidget {
  const AppEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            L10n.of(context).emptyPosts,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Assets.image.empty.image(width: 110, height: 110),
        ],
      ),
    );
  }
}

class AppSearchEmpty extends StatelessWidget {
  const AppSearchEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          L10n.of(context).searchEmptyResult,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        Assets.gif.error.image(width: 180, height: 180),
      ],
    );
  }
}
