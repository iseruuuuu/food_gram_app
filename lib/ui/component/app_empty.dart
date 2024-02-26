import 'package:flutter/material.dart';
import 'package:food_gram_app/core/gen/assets.gen.dart';

class AppEmpty extends StatelessWidget {
  const AppEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '投稿がありません',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Assets.image.empty.image(
            width: 100,
            height: 100,
          ),
        ],
      ),
    );
  }
}
