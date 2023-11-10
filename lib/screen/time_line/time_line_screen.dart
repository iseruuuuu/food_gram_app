import 'package:flutter/material.dart';
import 'package:food_gram_app/component/app_cell.dart';

class TimeLineScreen extends StatelessWidget {
  const TimeLineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6750A4),
      ),
      body: GridView.builder(
        itemCount: 15,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
        ),
        itemBuilder: (context, index) {
          return const AppCell();
        },
      ),
    );
  }
}
