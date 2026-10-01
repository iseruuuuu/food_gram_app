/// フィルタ後の件数で 1 ページを埋める。
///
/// 取得バッチに見えない行が混ざっても、バッチが上限まで返っているあいだは
/// ページを完了にしない。
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
    for (final item in batch) {
      if (items.length >= limit) {
        break;
      }
      if (!isVisible(item)) {
        continue;
      }
      items.add(item);
    }
    if (batch.length < batchSize) {
      sourceExhausted = true;
    }
  }

  bool get isFull => items.length >= limit;

  bool get isComplete => isFull || sourceExhausted;
}
