import 'package:flutter/material.dart';
import 'package:food_gram_app/core/local/providers/want_to_go_notifier.dart';
import 'package:food_gram_app/core/model/want_to_go_item.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/common/app_tab_error.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class WantToGoListScreen extends ConsumerWidget {
  const WantToGoListScreen({super.key});

  static const _accentOrange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(wantToGoNotifierProvider);
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg =
        isDark ? Theme.of(context).colorScheme.surface : Colors.white;
    final muted = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final border = isDark ? Colors.white24 : const Color(0xFFE5E5E5);

    return Scaffold(
      backgroundColor: sheetBg,
      appBar: AppBar(
        backgroundColor: sheetBg,
        surfaceTintColor: sheetBg,
        title: Text(
          t.wantToGo.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: listAsync.when(
        loading: () => const Center(child: AppContentLoading()),
        error: (_, __) => AppTabError.myPage(
          onRetry: () => ref.invalidate(wantToGoNotifierProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppEmpty(),
                    const SizedBox(height: 8),
                    Text(
                      t.wantToGo.emptyHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted),
                    ),
                  ],
                ),
              ),
            );
          }

          final sorted = List<WantToGoItem>.from(items)
            ..sort((a, b) => b.addedAt.compareTo(a.addedAt));

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = sorted[index];
              final dateLabel = _formatAddedDate(context, item.addedAt);

              return DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.place,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: t.wantToGo.removeFromList,
                            onPressed: () async {
                              await ref
                                  .read(wantToGoNotifierProvider.notifier)
                                  .removeById(item.id);
                            },
                            icon: Icon(Icons.close, color: muted, size: 20),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: muted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t.wantToGo.addedOn.replaceAll('{date}', dateLabel),
                            style: TextStyle(fontSize: 14, color: muted),
                          ),
                        ],
                      ),
                      const Gap(12),
                      Material(
                        color: isDark
                            ? _accentOrange.withValues(alpha: 0.18)
                            : const Color(0xFFFFF3E6),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => context.pushNamed(
                            RouterPath.myProfilePost,
                            extra: item.toRestaurant(),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: _accentOrange,
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    t.wantToGo.postAfterVisit,
                                    style: const TextStyle(
                                      color: _accentOrange,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: _accentOrange,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _formatAddedDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context);
  final candidates = <String>{
    locale.toString(),
    locale.languageCode,
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty)
      '${locale.languageCode}_${locale.countryCode}',
  };
  for (final tag in candidates) {
    try {
      return DateFormat('yyyy.MM.dd (E)', tag).format(date);
    } on Object {
      // try next candidate
    }
  }
  return DateFormat('yyyy.MM.dd').format(date);
}
