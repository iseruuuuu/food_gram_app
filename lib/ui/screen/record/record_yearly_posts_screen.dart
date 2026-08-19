import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_memories_section.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 過去の思い出・年間の記録から開く投稿一覧
class RecordYearlyPostsExtra {
  const RecordYearlyPostsExtra({
    required this.posts,
    this.year,
    this.title,
  });

  final int? year;
  final String? title;
  final List<Posts> posts;
}

class RecordYearlyPostsScreen extends HookConsumerWidget {
  const RecordYearlyPostsScreen({
    required this.posts,
    this.year,
    this.title,
    super.key,
  });

  final int? year;
  final String? title;
  final List<Posts> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sortedPosts = useMemoized(
      () {
        return [...posts]..sort((a, b) {
            final heartCompare = b.heart.compareTo(a.heart);
            if (heartCompare != 0) {
              return heartCompare;
            }
            return b.createdAt.compareTo(a.createdAt);
          });
      },
      [posts],
    );
    useEffect(
      () {
        ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
              name: AnalyticsEvent.recordYearOpen,
            );
        return null;
      },
      const [],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        surfaceTintColor:
            isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title: Column(
          children: [
            Text(
              title ??
                  t.myMapRecord.yearlyPostsTitle.replaceAll(
                    '{year}',
                    '${year ?? ''}',
                  ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (year != null)
              Text(
                t.myMapRecord.yearlyLikedOrder,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
          ],
        ),
      ),
      body: sortedPosts.isEmpty
          ? Center(
              child: Text(
                t.myMapRecord.noPostsYet,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: sortedPosts.length,
              separatorBuilder: (_, __) => const Gap(10),
              itemBuilder: (context, index) {
                final post = sortedPosts[index];
                return RecordRecentListTile(
                  post: post,
                  onTap: () {
                    EasyDebounce.debounce(
                      'record_yearly_post_tap',
                      const Duration(milliseconds: 200),
                      () async {
                        if (!context.mounted) {
                          return;
                        }
                        final result = await ref
                            .read(detailPostRepositoryProvider.notifier)
                            .getPostData(sortedPosts, index);
                        await result.whenOrNull(
                          success: (model) async {
                            if (!context.mounted) {
                              return;
                            }
                            await context.pushNamed(
                              RouterPath.myProfileDetail,
                              extra: model,
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
