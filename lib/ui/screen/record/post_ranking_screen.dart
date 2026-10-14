import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/public_post_ranking_provider.dart';
import 'package:food_gram_app/core/supabase/user/services/user_service.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 投稿数の合計での全体ランキング。行からプロフィールや投稿には進まない。
class PostRankingScreen extends HookConsumerWidget {
  const PostRankingScreen({super.key});

  static const _defaultIcon = 'assets/icon/icon1.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
              name: AnalyticsEvent.rankingOpen,
            );
        return null;
      },
      const [],
    );
    final t = Translations.of(context);
    final asyncRanking = ref.watch(publicPostRankingProvider);
    final currentUserId = ref.watch(currentUserProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final barColor =
        isLight ? Colors.white : Theme.of(context).colorScheme.surface;

    Future<void> refresh() async {
      ref.read(userServiceProvider.notifier).invalidatePublicPostCounts();
      ref.invalidate(publicPostRankingProvider);
      try {
        await ref.read(publicPostRankingProvider.future);
      } on Object {
        // 失敗時は provider の error を画面に出す。
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: barColor,
        surfaceTintColor: barColor,
        centerTitle: true,
        elevation: 0.5,
        title: Text(
          t.profile.rankingStats,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: asyncRanking.when(
        data: (entries) => RefreshIndicator(
          color: AppTheme.primaryOrange,
          onRefresh: refresh,
          child: entries.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  children: [
                    Text(
                      t.myMapRecord.rankListEmpty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) {
                    return Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).dividerColor.withValues(
                            alpha: 0.4,
                          ),
                    );
                  },
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isMine = entry.userId == currentUserId;
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final imagePath =
                        entry.image.isEmpty ? _defaultIcon : entry.image;
                    return ListTile(
                      // プロフィールへ進むと非公開投稿が見えるため、行は表示だけにする。
                      tileColor: isMine
                          ? AppTheme.primaryOrange.withValues(
                              alpha: isDark ? 0.18 : 0.12,
                            )
                          : null,
                      leading: SizedBox(
                        width: 44,
                        child: Text(
                          '${entry.rank}',
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _rankColor(entry.rank, isDark: isDark),
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          AppProfileImage(
                            imagePath: imagePath,
                            radius: 18,
                          ),
                          const Gap(10),
                          Expanded(
                            child: Text(
                              entry.name.isEmpty ? '—' : entry.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        t.myMapRecord.rankListCount.replaceAll(
                          '{count}',
                          '${entry.postCount}',
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isMine
                              ? AppTheme.primaryOrange
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryOrange,
          ),
        ),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.error.description1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Gap(12),
                TextButton(
                  onPressed: refresh,
                  child: Text(t.error.refreshButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _rankColor(int rank, {required bool isDark}) {
  return switch (rank) {
    1 => const Color(0xFFD4A017),
    2 => const Color(0xFF8E9AAB),
    3 => const Color(0xFFCD7F32),
    _ => isDark ? Colors.white54 : Colors.black45,
  };
}
