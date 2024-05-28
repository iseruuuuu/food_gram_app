import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:gap/gap.dart';

class AppEmpty extends StatelessWidget {
  const AppEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            L10n.of(context).empty,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
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
          L10n.of(context).search_empty,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Gap(30),
        Assets.image.empty.image(width: 80, height: 80),
      ],
    );
  }
}
