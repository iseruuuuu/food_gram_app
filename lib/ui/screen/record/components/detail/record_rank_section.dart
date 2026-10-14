import 'package:flutter/material.dart';
import 'package:food_gram_app/core/local/post_rank_history.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/post_count_rank_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/record_post_rank_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 記録タブ：食の軌跡の下に出す、投稿数ランキングの順位と変動。
class RecordRankSection extends ConsumerStatefulWidget {
  const RecordRankSection({super.key});

  @override
  ConsumerState<RecordRankSection> createState() => _RecordRankSectionState();
}

class _RecordRankSectionState extends ConsumerState<RecordRankSection>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refresh();
    }
  }

  void _refresh() {
    final userId = ref.read(currentUserProvider);
    if (userId == null) {
      return;
    }
    ref
      ..invalidate(postCountRankProvider(userId))
      ..invalidate(recordPostRankProvider(userId));
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider);
    if (userId == null) {
      return const SizedBox.shrink();
    }
    final asyncRank = ref.watch(recordPostRankProvider(userId));
    void openRanking() {
      context.pushNamed(RouterPath.postRanking);
    }

    return asyncRank.when(
      skipLoadingOnReload: true,
      data: (comparison) => _RankCard(
        comparison: comparison,
        onTap: openRanking,
      ),
      loading: () => _RankCard(onTap: openRanking, loading: true),
      error: (_, __) => _RankCard(onTap: openRanking),
    );
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({
    required this.onTap,
    this.comparison,
    this.loading = false,
  });

  final VoidCallback onTap;
  final PostRankComparison? comparison;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white70 : Colors.black87;
    final rankText = comparison == null
        ? '—'
        : t.profile.rankingPositionFormat.replaceAll(
            '{rank}',
            '${comparison!.currentRank}',
          );
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF241910) : const Color(0xFFFFF6EE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.primaryOrange.withValues(
                  alpha: isDark ? 0.28 : 0.18,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RankLine(
                    label: t.myMapRecord.rankTitle,
                    value: loading ? null : rankText,
                    valueColor: AppTheme.primaryOrange,
                    labelColor: labelColor,
                    emphasize: true,
                    showChevron: true,
                  ),
                  const Gap(8),
                  _RankLine(
                    label: t.myMapRecord.rankDayCompare,
                    value: _deltaText(t, comparison?.dayDelta),
                    valueColor: _deltaColor(context, comparison?.dayDelta),
                    labelColor: labelColor,
                  ),
                  const Gap(6),
                  _RankLine(
                    label: t.myMapRecord.rankMonthCompare,
                    value: _deltaText(t, comparison?.monthDelta),
                    valueColor: _deltaColor(context, comparison?.monthDelta),
                    labelColor: labelColor,
                  ),
                  if (comparison != null && comparison!.hasNoBaseline) ...[
                    const Gap(8),
                    Text(
                      t.myMapRecord.rankComparePending,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RankLine extends StatelessWidget {
  const _RankLine({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.labelColor,
    this.emphasize = false,
    this.showChevron = false,
  });

  final String label;
  final String? value;
  final Color valueColor;
  final Color labelColor;
  final bool emphasize;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (emphasize) ...[
          const Icon(
            Icons.emoji_events_outlined,
            size: 18,
            color: AppTheme.primaryOrange,
          ),
          const Gap(6),
        ],
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: emphasize ? 14 : 13,
              fontWeight: FontWeight.w800,
              color: labelColor,
            ),
          ),
        ),
        if (value == null)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryOrange,
            ),
          )
        else
          Text(
            value!,
            style: TextStyle(
              fontSize: emphasize ? 20 : 15,
              fontWeight: FontWeight.w900,
              color: valueColor,
              height: 1,
            ),
          ),
        if (showChevron)
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: labelColor,
          ),
      ],
    );
  }
}

String _deltaText(Translations t, int? delta) {
  if (delta == null) {
    return t.myMapRecord.rankDeltaUnknown;
  }
  if (delta > 0) {
    return t.myMapRecord.rankDeltaUp.replaceAll('{count}', '$delta');
  }
  if (delta < 0) {
    return t.myMapRecord.rankDeltaDown.replaceAll('{count}', '${delta.abs()}');
  }
  return t.myMapRecord.rankDeltaFlat;
}

Color _deltaColor(BuildContext context, int? delta) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (delta == null || delta == 0) {
    return isDark ? Colors.white54 : Colors.black45;
  }
  if (delta > 0) {
    return const Color(0xFF16A34A);
  }
  return const Color(0xFFEF4444);
}
