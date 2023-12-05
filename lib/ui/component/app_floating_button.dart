import 'package:flutter/material.dart';

class AppFloatingButton extends StatelessWidget {
  const AppFloatingButton({
    required this.onTap,
    super.key,
  });

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: FloatingActionButton(
        foregroundColor: Colors.black,
        backgroundColor: Colors.black,
        elevation: 10,
        shape: CircleBorder(side: BorderSide()),
        onPressed: onTap,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }
}
