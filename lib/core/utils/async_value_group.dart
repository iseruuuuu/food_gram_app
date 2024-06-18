import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/component/app_error_widget.dart';

/// 共通Widgetの一例
/// これはあくまでサンプルで、実際の共通クラスの具体的な内容は
/// 各プロジェクトに沿ったものを各自で実装することを推奨します
/// この場合エラー時もローディング時もデフォルトではSizedBox.shrink()
class AsyncValueSwitcher<T> extends StatelessWidget {
  const AsyncValueSwitcher({
    required this.asyncValue,
    required this.onData,
    super.key,
    this.onLoading,
    this.skipLoadingOnReload = true,
    this.skipLoadingOnRefresh = true,
    this.skipError = false,
    this.duration = const Duration(milliseconds: 300),
  });

  final AsyncValue<T> asyncValue;
  final Widget Function(T data) onData;
  final Widget? onLoading;
  final bool skipLoadingOnReload;
  final bool skipLoadingOnRefresh;
  final bool skipError;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      child: asyncValue.map(
        data: (data) => KeyedSubtree(
          key: ValueKey('onData_${T.toString()}_${data.value}'),
          child: onData(data.value),
        ),
        error: (error) => KeyedSubtree(
          key: ValueKey('onError_${T.toString()}_${error.error}'),
          child: AppErrorWidget(
            onTap: () => Navigator.pop(context),
          ),
        ),
        loading: (loading) => KeyedSubtree(
          key: ValueKey('onLoading_${T.toString()}'),
          child: onLoading ??
              Center(
                child: Assets.image.loading.image(
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
        ),
      ),
    );
  }
}

class AsyncValueGroup {
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
