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
    return InkWell(
      onTap: onTap,
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(
                icon,
                size: size ?? 28,
                color: color ?? Colors.black,
              ),
            ),
            const Gap(5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }
}
