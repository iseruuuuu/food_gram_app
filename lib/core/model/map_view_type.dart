/// マップの表示タイプ
enum MapViewType {
  /// 詳細ビュー（エリア単位）
  detail,

  /// 日本ビュー（都道府県単位）
  japan,

  /// 世界ビュー（国単位）
  world;

  String get label {
    switch (this) {
      case MapViewType.detail:
        return '記録';
      case MapViewType.japan:
        return '日本';
      case MapViewType.world:
        return '世界';
    }
  }
}
