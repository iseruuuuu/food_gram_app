import 'package:flutter/material.dart';
import 'package:food_gram_app/core/gen/assets.gen.dart';
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
            L10n.of(context).empty,
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Assets.image.empty.image(
            width: 110,
            height: 110,
          ),
        ],
      ),
    );
  }
}
