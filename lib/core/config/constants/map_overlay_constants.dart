/// マップ画面のオーバーレイ・カメラ・下シートの定数
class MapOverlayConstants {
  MapOverlayConstants._();

  // ランタイムスタイル（SymbolLayer）
  static const String runtimeSourceId = 'fg_posts_source';
  static const String runtimeLayerId = 'fg_posts_layer';
  static const String runtimeDotsLayerId = 'fg_posts_dots_layer';

  // ヒートマップ
  static const String heatmapSourceId = 'fg_heatmap_source';
  static const String heatmapLayerId = 'fg_heatmap_layer';

  /// ズームこの値以下でヒートマップ表示（0 なら実質オフ）
  static const double heatmapZoomThreshold = 0;

  /// ★ここで切替ズームを調整★（JSON の minzoom / maxzoom にも反映される）
  /// この値未満 → 赤い点 / この値以上 → カテゴリーピン
  static const double smallDotZoomThreshold = 8;

  /// 小さな赤ドットの iconSize（Annotation フォールバック用）
  static const double smallRedDotIconSize = 0.55;

  /// OSM Bright スプライトの標準マーカー（local / earth 共通 sprite URL）
  static const String styleDefaultMarkerIconId = 'marker_11';

  // カメラズーム
  /// 初期表示（現在地あり）
  static const double initial = 14.8;

  /// 現在地ボタン
  static const double currentLocation = 15.2;

  /// ピンタップ・近くの店舗一覧タップ
  static const double pinTap = 16.5;

  /// 投稿詳細などから店舗マップへ
  static const double fromPostDetail = 17;

  /// 位置情報なし時（日本全体）※互換・広域表示用
  static const double countryOverview = 3.8;

  /// ★位置情報なしの初期ズーム★（国全体なら 3.5〜5 付近）
  static const double localeFallback = 4;

  // 下シート
  /// 近くの店舗一覧（Overview）折りたたみ時（ハンドルのみ）※互換用
  static const double overviewCollapsedSize = 0.042;

  /// ボトムナビ上に常時見せる追加の高さ（px）
  static const double overviewOpenPeekPx = 56;

  /// 近くの店舗一覧（Overview）タップで開いたとき（さらに引き伸ばしたとき）
  static const double overviewExpandedSize = 0.36;

  /// 店舗詳細（Detail）の初期高さ比率
  static const double detailInitialChildSize = 0.37;
}
