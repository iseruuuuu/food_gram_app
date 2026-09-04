import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
import 'package:food_gram_app/core/supabase/user/services/user_service.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/helpers/haptic_feedback_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// アカウント登録直後に、何番目のユーザーかを祝う画面。
class RegistrationWelcomeScreen extends HookConsumerWidget {
  const RegistrationWelcomeScreen({super.key});

  static const _cream = Color(0xFFF5F0E8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final memberNumber = useState<int?>(null);
    final isLoading = useState(true);
    final confettiController = useMemoized(
      () => ConfettiController(duration: const Duration(seconds: 3)),
    );
    final numberController = useAnimationController(
      duration: const Duration(milliseconds: 700),
    );

    useEffect(
      () {
        var cancelled = false;
        Future<void> load() async {
          final number = await _fetchMemberNumber(ref);
          if (cancelled) {
            return;
          }
          if (number != null) {
            memberNumber.value = number;
          }
          isLoading.value = false;
          if (number == null) {
            return;
          }
          HapticFeedbackHelper.heavy();
          confettiController.play();
          await numberController.forward();
        }

        unawaited(load());
        return () {
          cancelled = true;
          confettiController.dispose();
        };
      },
      [confettiController, numberController],
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? Theme.of(context).colorScheme.surface : _cream;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final mutedColor = textColor.withValues(alpha: 0.7);
    final displayedNumber = memberNumber.value;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _goToTab(context);
      },
      child: Scaffold(
        backgroundColor: background,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    const Text('🎉', style: TextStyle(fontSize: 48)),
                    const Gap(16),
                    Text(
                      t.accountRegistration.welcomeTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.25,
                      ),
                    ),
                    const Gap(28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: isLoading.value
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              height: 88,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryBlue,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : displayedNumber != null
                              ? FadeTransition(
                                  key: const ValueKey('number'),
                                  opacity: numberController,
                                  child: ScaleTransition(
                                    scale: numberController.drive(
                                      Tween<double>(begin: 0.85, end: 1).chain(
                                        CurveTween(curve: Curves.easeOutBack),
                                      ),
                                    ),
                                    child: _MemberNumberText(
                                      template:
                                          t.accountRegistration.memberNumber,
                                      number: NumberFormat.decimalPattern(
                                        Localizations.localeOf(context)
                                            .toLanguageTag(),
                                      ).format(displayedNumber),
                                      textColor: textColor,
                                      numberColor: AppTheme.primaryBlue,
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  key: ValueKey('empty'),
                                  height: 8,
                                ),
                    ),
                    const Gap(24),
                    Text(
                      t.accountRegistration.body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: mutedColor,
                      ),
                    ),
                    const Spacer(flex: 3),
                    AppElevatedButton(
                      onPressed: () {
                        HapticFeedbackHelper.medium();
                        _goToTab(context);
                      },
                      title: t.accountRegistration.cta,
                      backgroundColor: AppTheme.primaryBlue,
                      horizontalInset: 24,
                    ),
                    const Gap(28),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.12,
                numberOfParticles: 18,
                maxBlastForce: 22,
                minBlastForce: 8,
                gravity: 0.22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _goToTab(BuildContext context) {
  if (!context.mounted) {
    return;
  }
  context.pushReplacementNamed(RouterPath.tab);
}

class _MemberNumberText extends StatelessWidget {
  const _MemberNumberText({
    required this.template,
    required this.number,
    required this.textColor,
    required this.numberColor,
  });

  final String template;
  final String number;
  final Color textColor;
  final Color numberColor;

  @override
  Widget build(BuildContext context) {
    final parts = template.split('{number}');
    final baseStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: textColor,
      height: 1.45,
    );
    if (parts.length != 2) {
      return Text(
        template.replaceAll('{number}', number),
        textAlign: TextAlign.center,
        style: baseStyle,
      );
    }
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: parts[0]),
          TextSpan(
            text: number,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: numberColor,
              height: 1.2,
            ),
          ),
          TextSpan(text: parts[1]),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

Future<int?> _fetchMemberNumber(WidgetRef ref) async {
  const delays = [
    Duration.zero,
    Duration(milliseconds: 400),
    Duration(milliseconds: 800),
  ];
  final uid = ref.read(currentUserProvider);
  for (var i = 0; i < delays.length; i++) {
    if (delays[i] > Duration.zero) {
      await Future<void>.delayed(delays[i]);
    }
    try {
      if (uid != null) {
        ref.read(userServiceProvider.notifier).invalidateUserCache(uid);
      }
      final result = await ref
          .read(userRepositoryProvider.notifier)
          .getCurrentUser()
          .timeout(const Duration(seconds: 4));
      final id = result.when(
        success: (user) => user.id,
        failure: (_) => null,
      );
      if (id != null && id > 0) {
        return id;
      }
    } on Exception catch (_) {
      continue;
    }
  }
  return null;
}
