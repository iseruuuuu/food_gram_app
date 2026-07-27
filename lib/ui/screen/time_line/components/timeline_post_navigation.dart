import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/timeline_detail_extra.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// タイムラインの投稿詳細へ遷移する共通処理
void openTimelinePostDetail({
  required BuildContext context,
  required WidgetRef ref,
  required List<Posts> allPosts,
  required Posts post,
  required VoidCallback refresh,
  String? categoryName,
}) {
  EasyDebounce.debounce(
    'click_detail',
    const Duration(milliseconds: 200),
    () async {
      final index = allPosts.indexWhere((p) => p.id == post.id);
      if (index < 0) {
        return;
      }
      ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
        name: AnalyticsEvent.timelinePostOpen,
        parameters: {AnalyticsParam.postId: post.id},
      );
      final postResult = await ref
          .read(detailPostRepositoryProvider.notifier)
          .getPostData(allPosts, index);
      await postResult.whenOrNull(
        success: (model) async {
          final extra = (categoryName != null && categoryName.isNotEmpty)
              ? TimelineDetailExtra(
                  model: model,
                  categoryName: categoryName,
                )
              : model;
          if (!context.mounted) {
            return;
          }
          final result = await context.pushNamed(
            RouterPath.timeLineDetail,
            extra: extra,
          );
          if (result != null) {
            refresh();
          }
        },
      );
    },
  );
}
