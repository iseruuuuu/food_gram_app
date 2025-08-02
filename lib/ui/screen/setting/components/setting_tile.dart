import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

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
                size: 32,
                color: const Color(0xFF0168B7),
              ),
            ),
            const Gap(5),
            FittedBox(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }
}
