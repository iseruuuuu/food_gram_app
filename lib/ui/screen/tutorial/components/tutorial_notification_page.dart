import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/theme/style/tutorial_style.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

class TutorialNotificationPage extends HookWidget {
  const TutorialNotificationPage({
    required this.isActive,
    super.key,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final samples = t.tutorial.notificationSamples;
    final animation = useAnimationController(
      duration: const Duration(milliseconds: 1100),
    );

    useEffect(
      () {
        if (isActive) {
          animation
            ..reset()
            ..forward();
        }
        return null;
      },
      [isActive],
    );

    final cards = [
      (title: samples.likeTitle, body: samples.likeBody),
      (title: samples.commentTitle, body: samples.commentBody),
      (title: samples.reminderTitle, body: samples.reminderBody),
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.paddingOf(context).top + 28,
              24,
              8,
            ),
            child: Column(
              children: [
                Text(
                  t.tutorial.notificationTitle,
                  style: TutorialStyle.notificationTitle(context),
                  textAlign: TextAlign.center,
                ),
                const Gap(14),
                Text(
                  t.tutorial.notificationSubTitle,
                  style: TutorialStyle.notificationSubTitle(context),
                  textAlign: TextAlign.center,
                ),
                const Gap(28),
                ...List.generate(cards.length, (index) {
                  final sample = cards[index];
                  final start = index * 0.12;
                  final end = (0.55 + index * 0.12).clamp(0.0, 1.0);
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Interval(
                      start,
                      end,
                      curve: Curves.easeOutCubic,
                    ),
                  );
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == cards.length - 1 ? 0 : 10,
                    ),
                    child: FadeTransition(
                      opacity: curved,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.18),
                          end: Offset.zero,
                        ).animate(curved),
                        child: _TutorialNotificationSampleCard(
                          appName: t.tutorial.notificationAppName,
                          timeLabel: t.tutorial.notificationNow,
                          title: sample.title,
                          body: sample.body,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}

class _TutorialNotificationSampleCard extends StatelessWidget {
  const _TutorialNotificationSampleCard({
    required this.appName,
    required this.timeLabel,
    required this.title,
    required this.body,
  });

  final String appName;
  final String timeLabel;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = colorScheme.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surface.withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: isDark ? 0.18 : 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Assets.image.appIcon.image(
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                            color: onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                  const Gap(3),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: onSurface,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
