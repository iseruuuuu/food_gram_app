import 'package:flutter/cupertino.dart';
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
      child: CupertinoButton(
        borderRadius: BorderRadius.circular(100),
        padding: EdgeInsets.zero,
        color: const Color(0xFFEADDFF),
        onPressed: onTap,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}
