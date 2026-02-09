import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/ui/screen/tab/tab_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const int _maxRetries = 20;
const Duration _scrollDuration = Duration(milliseconds: 300);

/// タブタップ時にスクロールを先頭へ戻す共有フック。
/// `scrollController.hasClients` が false の間はリトライし、
/// 最大リトライ後は必ず `scrollToTopForTabProvider` を null に戻す。
void useScrollToTopOnTabTrigger({
  required WidgetRef ref,
  required ScrollController scrollController,
  required int tabIndex,
  List<Object?> extraDeps = const [],
}) {
  final scrollToTopRequested = ref.watch(scrollToTopForTabProvider);

  useEffect(
    () {
      if (scrollToTopRequested == null ||
          scrollToTopRequested.tabIndex != tabIndex) {
        return null;
      }
      var cancelled = false;
      var retryCount = 0;

      void scrollToTop() {
        if (cancelled || !scrollController.hasClients) {
          return;
        }
        scrollController
            .animateTo(
          0,
          duration: _scrollDuration,
          curve: Curves.easeOutCubic,
        )
            .then((_) {
          if (!cancelled) {
            ref.read(scrollToTopForTabProvider.notifier).state = null;
          }
        });
      }

      void tryScroll() {
        if (cancelled) {
          return;
        }
        if (scrollController.hasClients) {
          scrollToTop();
        } else if (retryCount < _maxRetries) {
          retryCount++;
          WidgetsBinding.instance.addPostFrameCallback((_) => tryScroll());
        } else {
          if (!cancelled) {
            ref.read(scrollToTopForTabProvider.notifier).state = null;
          }
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) => tryScroll());
      return () {
        cancelled = true;
      };
    },
    [scrollToTopRequested, ...extraDeps],
  );
}
