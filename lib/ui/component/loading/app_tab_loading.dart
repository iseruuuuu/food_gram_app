import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

enum TabLoadingType { map, food, record, myPage }

class AppTabLoading extends StatefulWidget {
  const AppTabLoading({required this.type, super.key});
  const AppTabLoading.map({super.key}) : type = TabLoadingType.map;
  const AppTabLoading.food({super.key}) : type = TabLoadingType.food;
  const AppTabLoading.record({super.key}) : type = TabLoadingType.record;
  const AppTabLoading.myPage({super.key}) : type = TabLoadingType.myPage;

  final TabLoadingType type;

  @override
  State<AppTabLoading> createState() => _AppTabLoadingState();
}

class _AppTabLoadingState extends State<AppTabLoading>
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
    final t = Translations.of(context);
    final accent = Theme.of(context).colorScheme.onSurface;
    final config = switch (widget.type) {
      TabLoadingType.map => (
          icon: CupertinoIcons.location_fill,
          label: t.tab.map,
          message: t.tab.loadingMap,
          image: Assets.image.loadingMap,
        ),
      TabLoadingType.food => (
          icon: Icons.restaurant,
          label: t.tab.home,
          message: t.tab.loadingFood,
          image: Assets.image.loadingFood,
        ),
      TabLoadingType.record => (
          icon: Icons.menu_book,
          label: t.tab.myMap,
          message: t.tab.loadingRecord,
          image: Assets.image.loadingRecord,
        ),
      TabLoadingType.myPage => (
          icon: Icons.person,
          label: t.tab.myPage,
          message: t.tab.loadingMyPage,
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
                  Icon(config.icon, color: accent, size: 28),
                  const Gap(6),
                  Text(
                    config.label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accent,
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
              AnimatedBuilder(
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
                            color: accent.withValues(
                              alpha: isActive ? 1.0 : 0.25,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
