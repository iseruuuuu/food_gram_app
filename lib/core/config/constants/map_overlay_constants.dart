/// マップ画面のオーバーレイ・カメラ・下シートの定数
class MapOverlayConstants {
  MapOverlayConstants._();

  // ランタイムスタイル（SymbolLayer）
  static const String runtimeSourceId = 'fg_posts_source';
  static const String runtimeLayerId = 'fg_posts_layer';

  // ヒートマップ
  static const String heatmapSourceId = 'fg_heatmap_source';
  static const String heatmapLayerId = 'fg_heatmap_layer';

  /// ズームこの値以下でヒートマップ表示
  static const double heatmapZoomThreshold = 10;

  /// ズームこの値以下で小さな赤ドット表示
  static const double smallDotZoomThreshold = 13;

  /// 小さな赤ドットの iconSize（マップ上）
  static const double smallRedDotIconSize = 0.39;

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

  /// 位置情報なし時（日本全体）
  static const double countryOverview = 3.8;

  // 下シート
  /// 近くの店舗一覧（Overview）折りたたみ時（ハンドルのみ）
  static const double overviewCollapsedSize = 0.042;

  /// 近くの店舗一覧（Overview）タップで開いたとき
  static const double overviewExpandedSize = 0.36;

  /// 店舗詳細（Detail）の初期高さ比率
  static const double detailInitialChildSize = 0.28;
}
