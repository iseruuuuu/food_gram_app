import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PostShareRating extends StatelessWidget {
  const PostShareRating({
    required this.star,
    this.color = Colors.white,
    this.iconSize = 18,
    this.fontSize = 16,
    super.key,
  });

  final double star;
  final Color color;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    if (star <= 0) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
          size: iconSize,
        ),
        const Gap(4),
        Text(
          star.toStringAsFixed(1),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
