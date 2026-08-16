import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

/// 記録タブ：まだ投稿していない人向けの空状態
class RecordEmptySection extends StatelessWidget {
  const RecordEmptySection({
    required this.onRecordTap,
    super.key,
  });

  final VoidCallback onRecordTap;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            Assets.lottie.recordNopost,
            width: 160,
            height: 160,
            fit: BoxFit.contain,
          ),
          const Gap(16),
          Text(
            t.myMapRecord.emptyTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
          const Gap(8),
          Text(
            t.myMapRecord.emptyBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const Gap(24),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 52,
            child: ElevatedButton(
              onPressed: onRecordTap,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                t.myMapRecord.emptyCta,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
