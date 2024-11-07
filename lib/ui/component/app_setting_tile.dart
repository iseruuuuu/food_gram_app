import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AppSettingTile extends StatelessWidget {
  const AppSettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.size,
    this.color,
    super.key,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final String title;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              // child: icon,
              child: Icon(
                icon,
                size: size ?? 28,
                color: color ?? Colors.black,
              ),
            ),
          ),
          Gap(5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(10),
        ],
      ),
    );
  }
}
