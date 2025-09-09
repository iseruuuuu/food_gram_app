import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppProfileHeaderSkeleton extends StatelessWidget {
  const AppProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey.shade300,
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 50, bottom: 10),
                child: Column(
                  children: [
                    const Gap(8),
                    Container(
                      width: 120,
                      height: 20,
                      color: Colors.grey.shade300,
                    ),
                    const Gap(8),
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const Gap(8),
                    Container(
                      width: 200,
                      height: 16,
                      color: Colors.grey.shade200,
                    ),
                    const Gap(8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ColumnSkeleton(),
                        _ColumnSkeleton(),
                        _ColumnSkeleton(),
                      ],
                    ),
                    const Gap(16),
                    Container(
                      width: double.infinity,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const Gap(16),
                    Container(
                      width: double.infinity,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
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
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
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
  const _ColumnSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width / 3.5,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 18,
            color: Colors.grey.shade300,
          ),
          const Gap(4),
          Container(
            width: 40,
            height: 12,
            color: Colors.grey.shade200,
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

class AppPostDetailSkeleton extends StatelessWidget {
  const AppPostDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width / 1.2;
    return Skeletonizer(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('usernameeeeee', style: TextStyle(color: Colors.grey)),
                  Text('@username'),
                ],
              ),
            ],
          ),
          Container(
            height: screenWidth,
            width: screenWidth,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'foodName',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'In レストラン',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'すごく美味しかったよぉぉぉぉ',
                  style: TextStyle(
                    color: Colors.grey,
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
