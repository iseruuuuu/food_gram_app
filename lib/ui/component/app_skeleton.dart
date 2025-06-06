import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppHeaderSkeleton extends StatelessWidget {
  const AppHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, -4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const Spacer(),
                    const Column(
                      children: [
                        Text(
                          '100',
                          style: TextStyle(fontSize: 24),
                        ),
                        Text(
                          '投稿数',
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                    const Gap(30),
                    const Column(
                      children: [
                        Text(
                          '100',
                          style: TextStyle(fontSize: 24),
                        ),
                        Text(
                          'ポイント',
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Name',
                  style: TextStyle(fontSize: 24),
                ),
                const Gap(4),
                const Text(
                  'Introduction',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
