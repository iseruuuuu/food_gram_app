import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/location/prefecture_display.dart';
import 'package:food_gram_app/ui/screen/map/components/map_prefecture_fill_layer.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// 記録タブ：日本列島だけを中心に見せる都道府県塗りつぶし地図
class RecordJapanFillMap extends StatefulWidget {
  const RecordJapanFillMap({
    required this.posts,
    this.interactive = true,
    this.onMapTap,
    super.key,
  });

  final List<Posts> posts;
  final bool interactive;
  final void Function(double lat, double lng)? onMapTap;

  @override
  State<RecordJapanFillMap> createState() => _RecordJapanFillMapState();
}

class _RecordJapanFillMapState extends State<RecordJapanFillMap> {
  /// 本州が画面中央に来る初期カメラ
  static const _japanCamera = CameraPosition(
    target: LatLng(36.8, 137.9),
    zoom: 3,
  );

  /// パンできる範囲は沖縄まで含める
  static final _japanPanBounds = LatLngBounds(
    southwest: const LatLng(23.8, 122.8),
    northeast: const LatLng(46.3, 149),
  );

  MapLibreMapController? _controller;
  bool _layersReady = false;

  @override
  void didUpdateWidget(covariant RecordJapanFillMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasMapRelevantChanges(oldWidget.posts, widget.posts)) {
      return;
    }
    _layersReady = false;
    _renderOverlays();
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  bool _hasMapRelevantChanges(List<Posts> previous, List<Posts> next) {
    String signature(List<Posts> posts) {
      return posts
          .where((post) => post.lat != 0 && post.lng != 0)
          .map((post) => '${post.id}:${post.lat}:${post.lng}')
          .join('|');
    }

    return signature(previous) != signature(next);
  }

  String _styleString(bool isDark) {
    final background = isDark ? '#141414' : '#F6F1EA';
    return '''
{
  "version": 8,
  "name": "Japan Atlas",
  "sources": {
    "dummy": {
      "type": "geojson",
      "data": { "type": "FeatureCollection", "features": [] }
    }
  },
  "layers": [
    {
      "id": "background",
      "type": "background",
      "paint": { "background-color": "$background" }
    }
  ]
}
''';
  }

  Future<void> _renderOverlays() async {
    final controller = _controller;
    if (controller == null || _layersReady || !mounted) {
      return;
    }
    try {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      await MapPrefectureFillLayer.render(
        controller,
        prefecturePostCounts: recordPrefecturePostCounts(widget.posts),
        palette: MapPrefectureFillPalette.atlas,
        isDark: isDark,
      );
      await _fitJapan(controller);
      _layersReady = true;
    } on Exception catch (e, st) {
      debugPrint('RecordJapanFillMap overlay failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _fitJapan(MapLibreMapController controller) async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted || _controller != controller) {
      return;
    }
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(_japanCamera),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MapLibreMap(
      key: ValueKey('recordJapanFillMap_${isDark ? 'dark' : 'light'}'),
      styleString: _styleString(isDark),
      initialCameraPosition: _japanCamera,
      minMaxZoomPreference: const MinMaxZoomPreference(2.8, 7.5),
      cameraTargetBounds: CameraTargetBounds(_japanPanBounds),
      compassEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      scrollGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      attributionButtonPosition: AttributionButtonPosition.bottomLeft,
      foregroundLoadColor:
          isDark ? const Color(0xFF141414) : const Color(0xFFF6F1EA),
      gestureRecognizers: widget.interactive
          ? const {
              Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
            }
          : const <Factory<OneSequenceGestureRecognizer>>{},
      onMapCreated: (controller) {
        _layersReady = false;
        _controller = controller;
      },
      onStyleLoadedCallback: _renderOverlays,
      onMapClick: widget.onMapTap == null
          ? null
          : (_, latLng) {
              widget.onMapTap!(latLng.latitude, latLng.longitude);
            },
    );
  }
}
