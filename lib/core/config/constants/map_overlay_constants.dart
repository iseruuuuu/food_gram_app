/// マップオーバーレイ（ピン・ヒートマップ）の定数
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
}
