/// フィルタ後の件数で 1 ページを埋める。
///
/// 取得バッチに見えない行が混ざっても、そのバッチを最後まで見て
/// 件数が要求サイズ未満のときだけ [sourceExhausted] にする。
/// ページがバッチの途中で埋まったときは、同じバッチの続きが残っているので
/// 取得元は尽きていない。
class VisiblePage<T> {
  VisiblePage({required this.limit});

  final int limit;
  final List<T> items = [];
  bool sourceExhausted = false;

  void addBatch(
    List<T> batch, {
    required int batchSize,
    required bool Function(T item) isVisible,
  }) {
    var scannedAll = true;
    for (final item in batch) {
      if (items.length >= limit) {
        scannedAll = false;
        break;
      }
      if (!isVisible(item)) {
        continue;
      }
      items.add(item);
    }
    if (scannedAll && batch.length < batchSize) {
      sourceExhausted = true;
    }
  }

  bool get isFull => items.length >= limit;

  bool get isComplete => isFull || sourceExhausted;
}
