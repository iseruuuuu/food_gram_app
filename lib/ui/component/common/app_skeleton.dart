import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppProfileHeaderSkeleton extends StatelessWidget {
  const AppProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonPrimary =
        isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final skeletonSecondary =
        isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    return Skeletonizer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: skeletonPrimary,
              ),
              Container(
                color: scheme.surface,
                padding: const EdgeInsets.only(top: 50, bottom: 10),
                child: Column(
                  children: [
                    const Gap(8),
                    Container(
                      width: 120,
                      height: 20,
                      color: skeletonPrimary,
                    ),
                    const Gap(8),
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: skeletonSecondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const Gap(8),
                    Container(
                      width: 200,
                      height: 16,
                      color: skeletonSecondary,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ColumnSkeleton(
                          primary: skeletonPrimary,
                          secondary: skeletonSecondary,
                        ),
                        _ColumnSkeleton(
                          primary: skeletonPrimary,
                          secondary: skeletonSecondary,
                        ),
                        _ColumnSkeleton(
                          primary: skeletonPrimary,
                          secondary: skeletonSecondary,
                        ),
                      ],
                    ),
                    const Gap(16),
                    Container(
                      width: double.infinity,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: skeletonSecondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Gap(16),
                    Container(
                      width: double.infinity,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: skeletonSecondary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 105,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: skeletonPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.surface,
                    width: 4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnSkeleton extends StatelessWidget {
  const _ColumnSkeleton({
    required this.primary,
    required this.secondary,
  });

  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width / 3.5,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 18,
            color: primary,
          ),
          const Gap(4),
          Container(
            width: 40,
            height: 12,
            color: secondary,
          ),
        ],
      ),
    );
  }
}

class AppListViewSkeleton extends StatelessWidget {
  const AppListViewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width / 3;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor =
        isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    return Skeletonizer(
      child: Column(
        children: List.generate(5, (index) {
          return Row(
            children: List.generate(3, (gridIndex) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  height: screenWidth,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Assets.image.food.image(width: 0, height: 0),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}

class AppSearchListViewSkeleton extends StatelessWidget {
  const AppSearchListViewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor =
        isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    return Skeletonizer(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: placeholderColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Assets.image.food.image(
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 近隣レストランモーダル用のスケルトン
class AppNearbyRestaurantsSkeleton extends StatelessWidget {
  const AppNearbyRestaurantsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 180,
                height: 16,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const Gap(8),
              Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      height: 90,
                      margin: EdgeInsets.only(right: i == 2 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AppPostDetailSkeleton extends StatelessWidget {
  const AppPostDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width / 1.2;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final textMuted = scheme.onSurfaceVariant;
    return Skeletonizer(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: skeletonColor,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'usernameeeeee',
                    style: TextStyle(color: textMuted),
                  ),
                  Text(
                    '@username',
                    style: TextStyle(color: textMuted),
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: screenWidth,
            width: screenWidth,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const Gap(16),
          Wrap(
            spacing: 10,
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Like')),
              ElevatedButton(onPressed: () {}, child: const Text('Like')),
              ElevatedButton(onPressed: () {}, child: const Text('Like')),
              ElevatedButton(onPressed: () {}, child: const Text('Like')),
            ],
          ),
          SizedBox(
            width: screenWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'foodName',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'In レストラン',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'すごく美味しかったよぉぉぉぉ',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
