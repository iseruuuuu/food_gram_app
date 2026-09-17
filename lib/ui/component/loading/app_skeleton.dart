import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/screen/map/components/map_area_restaurant_card.dart';
import 'package:gap/gap.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AppSkeletonPalette {
  const AppSkeletonPalette({
    required this.primary,
    required this.secondary,
  });

  factory AppSkeletonPalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppSkeletonPalette(
      primary: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
      secondary: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
    );
  }

  final Color primary;
  final Color secondary;
}

class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    this.width,
    this.height,
    this.color,
    this.radius = 0,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final Color? color;
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final palette = AppSkeletonPalette.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? palette.primary,
        shape: shape,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

/// プロフィールヘッダー用スケルトン。
class AppProfileHeaderSkeleton extends StatelessWidget {
  const AppProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = AppSkeletonPalette.of(context);
    return Skeletonizer(
      child: ColoredBox(
        color: scheme.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppSkeletonBox(
                    width: 88,
                    height: 88,
                    color: palette.primary,
                    shape: BoxShape.circle,
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeletonBox(
                          width: 140,
                          height: 20,
                          color: palette.primary,
                        ),
                        const Gap(8),
                        AppSkeletonBox(
                          width: 100,
                          height: 14,
                          color: palette.secondary,
                        ),
                        const Gap(10),
                        AppSkeletonBox(
                          width: 150,
                          height: 24,
                          color: palette.secondary,
                          radius: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(14),
              AppSkeletonBox(
                width: 220,
                height: 14,
                color: palette.secondary,
              ),
              const Gap(6),
              AppSkeletonBox(
                width: 180,
                height: 14,
                color: palette.secondary,
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ColumnSkeleton(palette: palette),
                  _ColumnSkeleton(palette: palette),
                  _ColumnSkeleton(palette: palette),
                ],
              ),
              const Gap(16),
              AppSkeletonBox(
                width: double.infinity,
                height: 40,
                color: palette.secondary,
                radius: 6,
              ),
              const Gap(12),
              AppSkeletonBox(
                width: double.infinity,
                height: 40,
                color: palette.secondary,
                radius: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColumnSkeleton extends StatelessWidget {
  const _ColumnSkeleton({required this.palette});

  final AppSkeletonPalette palette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width / 3.5,
      child: Column(
        children: [
          AppSkeletonBox(
            width: 32,
            height: 18,
            color: palette.primary,
          ),
          const Gap(4),
          AppSkeletonBox(
            width: 40,
            height: 12,
            color: palette.secondary,
          ),
        ],
      ),
    );
  }
}

/// 投稿グリッド（3列）用スケルトン。
class AppListViewSkeleton extends StatelessWidget {
  const AppListViewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width / 3;
    final palette = AppSkeletonPalette.of(context);
    return Skeletonizer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(5, (index) {
          return Row(
            children: List.generate(3, (gridIndex) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  height: screenWidth,
                  decoration: BoxDecoration(
                    color: palette.secondary,
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

/// 横スクロールの画像リスト用スケルトン。
class AppSearchListViewSkeleton extends StatelessWidget {
  const AppSearchListViewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppSkeletonPalette.of(context);
    return Skeletonizer(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.secondary,
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

/// 近隣レストランモーダル用のスケルトン（横スクロールカード）。
class AppNearbyRestaurantsSkeleton extends StatelessWidget {
  const AppNearbyRestaurantsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppSkeletonPalette.of(context);
    return Skeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: MapAreaRestaurantCard.height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              primary: false,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonBox(
                      width: MapAreaRestaurantCard.imageSize,
                      height: MapAreaRestaurantCard.imageSize,
                      color: palette.secondary,
                      radius: 16,
                    ),
                    const Gap(6),
                    AppSkeletonBox(
                      width: 88,
                      height: 14,
                      color: palette.secondary,
                      radius: 6,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 投稿詳細用スケルトン。
class AppPostDetailSkeleton extends StatelessWidget {
  const AppPostDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width / 1.2;
    final palette = AppSkeletonPalette.of(context);
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
                  backgroundColor: palette.primary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'usernameeeeee',
                    style: TextStyle(color: textMuted),
                  ),
                ],
              ),
            ],
          ),
          AppSkeletonBox(
            width: screenWidth,
            height: screenWidth,
            color: palette.primary,
            radius: 12,
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

/// 通知・検索・リスト画面用の汎用スケルトン。
class AppListSkeleton extends StatelessWidget {
  const AppListSkeleton({
    super.key,
    this.itemCount = 8,
    this.shrinkWrap = false,
  });

  final int itemCount;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final palette = AppSkeletonPalette.of(context);
    return Skeletonizer(
      child: ListView.separated(
        shrinkWrap: shrinkWrap,
        physics: shrinkWrap
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Row(
            children: [
              AppSkeletonBox(
                width: 72,
                height: 72,
                color: palette.primary,
                radius: 12,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonBox(
                      width: double.infinity,
                      height: 16,
                      color: palette.primary,
                      radius: 4,
                    ),
                    const Gap(8),
                    AppSkeletonBox(
                      width: 140,
                      height: 12,
                      color: palette.secondary,
                      radius: 4,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
