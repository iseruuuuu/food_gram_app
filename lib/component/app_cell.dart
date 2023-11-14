import 'package:flutter/material.dart';

class AppCell extends StatelessWidget {
  const AppCell({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 3,
      height: MediaQuery.of(context).size.width / 3,
      color: Colors.blue,
    );
  }
}
