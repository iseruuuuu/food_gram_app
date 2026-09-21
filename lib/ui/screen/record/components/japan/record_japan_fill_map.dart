import 'dart:math' show Point;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/core/utils/location/prefecture_display.dart';
import 'package:food_gram_app/ui/screen/map/components/map_prefecture_fill_layer.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// 記録タブ：日本列島全体を見せる都道府県塗りつぶし地図
class RecordJapanFillMap extends StatefulWidget {
  const RecordJapanFillMap({
    required this.posts,
    this.interactive = true,
    this.onMapTap,
    this.onPinTap,
    super.key,
  });

  final List<Posts> posts;
  final bool interactive;
  final void Function(double lat, double lng)? onMapTap;
  final void Function(List<Posts> posts)? onPinTap;

  @override
  State<RecordJapanFillMap> createState() => _RecordJapanFillMapState();
}

class _RecordJapanFillMapState extends State<RecordJapanFillMap> {
  static const _pinSourceId = 'fg_japan_atlas_pins';
  static const _pinLayerId = 'fg_japan_atlas_pins_layer';

  /// 北海道〜沖縄が収まる初期カメラ
  static const _japanCamera = CameraPosition(
    target: LatLng(37.6, 137.6),
    zoom: 3.2,
  );

  /// パンできる範囲は沖縄まで含める
  static final _japanPanBounds = LatLngBounds(
    southwest: const LatLng(23.8, 122.8),
    northeast: const LatLng(46.3, 149),
  );

  /// 初期表示で列島全体が収まる範囲
  static final _japanFitBounds = LatLngBounds(
    southwest: const LatLng(24, 122.9),
    northeast: const LatLng(45.7, 146.2),
  );

  MapLibreMapController? _controller;
  bool _layersReady = false;
  bool _didFitJapan = false;
  DateTime? _lastPinTapAt;

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

  List<Posts> get _pinPosts {
    return widget.posts
        .where((post) => post.lat != 0 && post.lng != 0)
        .where(_isInJapan)
        .toList();
  }

  bool _isInJapan(Posts post) {
    return CountryDetector.getCountryCode(post.lat, post.lng) == 'JP';
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
      await CountryDetector.ensureLoaded();
      final isDark = Theme.of(context).brightness == Brightness.dark;
      await MapPrefectureFillLayer.render(
        controller,
        prefecturePostCounts: recordPrefecturePostCounts(widget.posts),
        palette: MapPrefectureFillPalette.atlas,
        isDark: isDark,
      );
      await _renderPins(controller);
      if (!_didFitJapan) {
        await _fitJapan(controller);
        _didFitJapan = true;
      }
      _layersReady = true;
    } on Exception catch (e, st) {
      debugPrint('RecordJapanFillMap overlay failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _renderPins(MapLibreMapController controller) async {
    try {
      try {
        await controller.removeLayer(_pinLayerId);
      } on Exception catch (_) {}
      try {
        await controller.removeSource(_pinSourceId);
      } on Exception catch (_) {}

      final features = _pinPosts
          .map(
            (post) => {
              'type': 'Feature',
              'id': post.id,
              'geometry': {
                'type': 'Point',
                'coordinates': [post.lng, post.lat],
              },
              'properties': {
                'postId': post.id,
              },
            },
          )
          .toList();

      await controller.addSource(
        _pinSourceId,
        GeojsonSourceProperties(
          data: {
            'type': 'FeatureCollection',
            'features': features,
          },
        ),
      );
      await controller.addCircleLayer(
        _pinSourceId,
        _pinLayerId,
        const CircleLayerProperties(
          circleRadius: 6,
          circleColor: '#F44336',
          circleStrokeWidth: 1.5,
          circleStrokeColor: '#FFFFFF',
          circleOpacity: 0.92,
        ),
      );
    } on Exception catch (e, st) {
      debugPrint('RecordJapanFillMap pins failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _fitJapan(MapLibreMapController controller) async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted || _controller != controller) {
      return;
    }
    await controller.moveCamera(
      CameraUpdate.newLatLngBounds(
        _japanFitBounds,
        left: 20,
        top: 20,
        right: 20,
        bottom: 20,
      ),
    );
  }

  List<Posts> _postsNear(double lat, double lng) {
    const nearby = 0.003;
    final hits = _pinPosts
        .where(
          (post) =>
              (post.lat - lat).abs() <= nearby &&
              (post.lng - lng).abs() <= nearby,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return hits;
  }

  void _handleFeatureTap(
    Point<double> point,
    LatLng latLng,
    String id,
    String layerId,
    Annotation? annotation,
  ) {
    if (layerId != _pinLayerId) {
      return;
    }
    _lastPinTapAt = DateTime.now();
    var tapped = _postsNear(latLng.latitude, latLng.longitude);
    if (tapped.isEmpty) {
      final postId = int.tryParse(id);
      if (postId != null) {
        tapped = _pinPosts.where((post) => post.id == postId).toList();
      }
    }
    if (tapped.isEmpty) {
      return;
    }
    widget.onPinTap?.call(tapped);
  }

  bool _isRecentPinTap() {
    final last = _lastPinTapAt;
    return last != null &&
        DateTime.now().difference(last) < const Duration(milliseconds: 350);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MapLibreMap(
      key: ValueKey('recordJapanFillMap_${isDark ? 'dark' : 'light'}'),
      styleString: _styleString(isDark),
      initialCameraPosition: _japanCamera,
      minMaxZoomPreference: const MinMaxZoomPreference(2.2, 10),
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
        _didFitJapan = false;
        _controller = controller;
        controller.onFeatureTapped.add(_handleFeatureTap);
      },
      onStyleLoadedCallback: _renderOverlays,
      onMapClick: (_, latLng) {
        if (_isRecentPinTap()) {
          return;
        }
        widget.onMapTap?.call(latLng.latitude, latLng.longitude);
      },
    );
  }
}
