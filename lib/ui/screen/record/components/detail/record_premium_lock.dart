import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:gap/gap.dart';

/// 記録タブ共通のカード装飾
BoxDecoration recordSectionCardDecoration({required bool isDark}) {
  return BoxDecoration(
    color: isDark ? const Color(0xFF161616) : Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 16,
        offset: const Offset(0, 5),
      ),
    ],
  );
}

/// Premiumの続きを見たくなるロックCTA
class RecordPremiumLockBanner extends StatelessWidget {
  const RecordPremiumLockBanner({
    required this.message,
    required this.ctaLabel,
    required this.onTap,
    super.key,
  });

  final String message;
  final String ctaLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B2633) : const Color(0xFFEAF3FE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppTheme.primaryOrange.withValues(alpha: 0.35)
                  : const Color(0xFFBFD9F5),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: isDark ? Colors.white70 : AppTheme.primaryOrange,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF7A3E0B),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    ctaLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
