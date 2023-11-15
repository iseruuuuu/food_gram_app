import 'package:flutter/material.dart';
import 'package:food_gram_app/screen/detail/detail_post_screen.dart';

class AppCell extends StatelessWidget {
  const AppCell({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPostScreen(),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        height: MediaQuery.of(context).size.width / 3,
        color: Colors.blue,
      ),
    );
  }
}
