import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as fcm;

/// 画像ディスクキャッシュ。
///
/// - 利用中は件数・期限を抑えて肥大化を防ぐ
/// - 完全終了後の次回起動時、または設定の明示クリアで空にする
/// - ホームへ戻るだけでは消さない（アプリ切替時の再ダウンロードを避ける）
final class FoodGramImageCache {
  FoodGramImageCache._();

  static const _key = 'foodGramImageCache';

  /// 利用中の上限: 件数を抑え、長時間放置で肥大しないようにする。
  static final fcm.CacheManager instance = fcm.CacheManager(
    fcm.Config(
      _key,
      stalePeriod: const Duration(hours: 1),
      maxNrOfCacheObjects: 50,
    ),
  );

  /// [CachedNetworkImage] / [CachedNetworkImageProvider] の既定キャッシュを差し替える。
  static void installAsDefault() {
    CachedNetworkImageProvider.defaultCacheManager = instance;
  }

  /// ディスクキャッシュと Flutter のメモリ画像キャッシュを空にする。
  ///
  /// 過去に [DefaultCacheManager] へ溜まった分も合わせて消す。
  static Future<void> clear() async {
    await Future.wait<void>([
      instance.emptyCache(),
      fcm.DefaultCacheManager().emptyCache(),
    ]);
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
  }
}
