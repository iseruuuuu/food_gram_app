import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/ui/component/common/app_error_widget.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';

class AsyncValueSwitcher<T> extends StatelessWidget {
  const AsyncValueSwitcher({
    required this.asyncValue,
    required this.onData,
    required this.onErrorTap,
    super.key,
    this.onError,
    this.onLoading,
    this.skipLoadingOnReload = true,
    this.skipLoadingOnRefresh = true,
    this.skipError = false,
    this.duration = const Duration(milliseconds: 300),
  });

  final AsyncValue<T> asyncValue;
  final Widget Function(T data) onData;
  final Widget? onLoading;
  final Widget Function(Object, StackTrace)? onError;
  final bool skipLoadingOnReload;
  final bool skipLoadingOnRefresh;
  final bool skipError;
  final Duration duration;
  final VoidCallback onErrorTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: asyncValue.when(
        skipLoadingOnReload: skipLoadingOnReload,
        skipLoadingOnRefresh: skipLoadingOnRefresh,
        skipError: skipError,
        data: (data) => KeyedSubtree(
          key: const ValueKey('onData'),
          child: onData(data),
        ),
        error: (e, s) => KeyedSubtree(
          key: const ValueKey('onError'),
          child: AppErrorWidget(
            onTap: onErrorTap,
          ),
        ),
        loading: () => KeyedSubtree(
          key: const ValueKey('onLoading'),
          child: onLoading ?? const Center(child: AppContentLoading()),
        ),
      ),
    );
  }
}

class AsyncValueGroup {
  const AsyncValueGroup._();

  static AsyncValue<(T1, T2)> group2<T1, T2>(
    AsyncValue<T1> t1,
    AsyncValue<T2> t2,
  ) {
    if (t1 is AsyncLoading || t2 is AsyncLoading) {
      return const AsyncLoading();
    }
    try {
      return AsyncData((t1.value as T1, t2.value as T2));
    } on Exception catch (e, st) {
      return AsyncError(e, st);
    }
  }
}
