import 'package:flutter/services.dart';

/// アプリ共通の触覚フィードバック。
class HapticFeedbackHelper {
  const HapticFeedbackHelper._();

  /// タブ切り替え。頻繁なので軽く。
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// 星・いいね。小さな達成感、連打でも負担にならない強さ。
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// 投稿ボタン・送信・保存。操作の確定を明確にする。
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// 投稿完了。最も重要で、達成感を出す。
  static void heavy() {
    HapticFeedback.heavyImpact();
  }
}
