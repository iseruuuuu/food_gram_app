/// 投稿処理の協調的キャンセル（タイムアウト時に後続ステップを止める）
class PostSubmitCancellation {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;
}

class PostSubmitCancelledException implements Exception {
  const PostSubmitCancelledException();

  @override
  String toString() => 'PostSubmitCancelledException';
}
