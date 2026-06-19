import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

enum TabLoadingType { map, food, record, myPage }

class AppTabLoading extends StatelessWidget {
  const AppTabLoading({required this.type, super.key});
  const AppTabLoading.map({super.key}) : type = TabLoadingType.map;
  const AppTabLoading.food({super.key}) : type = TabLoadingType.food;
  const AppTabLoading.record({super.key}) : type = TabLoadingType.record;
  const AppTabLoading.myPage({super.key}) : type = TabLoadingType.myPage;

  final TabLoadingType type;

  static const _mapColor = Color(0xFF7DA453);
  static const _foodColor = Color(0xFFE8945A);
  static const _recordColor = Color(0xFF7DA453);
  static const _myPageColor = Color(0xFFB8956A);

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final config = switch (type) {
      TabLoadingType.map => (
          icon: CupertinoIcons.location_fill,
          label: t.tab.map,
          message: t.tab.loadingMap,
          color: _mapColor,
          image: Assets.image.loadingMap,
        ),
      TabLoadingType.food => (
          icon: Icons.restaurant,
          label: t.tab.home,
          message: t.tab.loadingFood,
          color: _foodColor,
          image: Assets.image.loadingFood,
        ),
      TabLoadingType.record => (
          icon: Icons.menu_book,
          label: t.tab.myMap,
          message: t.tab.loadingRecord,
          color: _recordColor,
          image: Assets.image.loadingRecord,
        ),
      TabLoadingType.myPage => (
          icon: Icons.person,
          label: t.tab.myPage,
          message: t.tab.loadingMyPage,
          color: _myPageColor,
          image: Assets.image.loadingMypage,
        ),
    };

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(config.icon, color: config.color, size: 28),
                  const Gap(6),
                  Text(
                    config.label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: config.color,
                    ),
                  ),
                ],
              ),
              config.image.image(width: 240, height: 240, fit: BoxFit.contain),
              Text(
                config.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
              const Gap(20),
              _TabLoadingDots(color: config.color),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabLoadingDots extends StatefulWidget {
  const _TabLoadingDots({required this.color});

  final Color color;

  @override
  State<_TabLoadingDots> createState() => _TabLoadingDotsState();
}

class _TabLoadingDotsState extends State<_TabLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final activeIndex = (_controller.value * 3).floor() % 3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final isActive = index == activeIndex;
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: isActive ? 1.0 : 0.25),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
