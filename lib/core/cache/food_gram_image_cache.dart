import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as fcm;

/// セッション向けの画像ディスクキャッシュ。
///
/// - アプリ起動中のみ使う想定（件数・期限を抑える）
/// - バックグラウンド移行時・明示クリア時・次回起動時に空にする
final class FoodGramImageCache {
  FoodGramImageCache._();

  static const _key = 'foodGramImageCache';

  /// 起動中の上限: 件数を抑え、長時間放置で肥大しないようにする。
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
