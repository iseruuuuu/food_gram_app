import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/core/utils/location/prefecture_detector.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/map/components/map_prefecture_fill_layer.dart';
import 'package:gap/gap.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// 記録タブ：食の旅マップ（世界にピン＋訪れた領域）
class RecordJourneyMapSection extends StatelessWidget {
  const RecordJourneyMapSection({
    required this.posts,
    required this.cardColor,
    required this.onSeeMore,
    super.key,
  });

  final List<Posts> posts;
  final Color cardColor;
  final VoidCallback onSeeMore;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.myMapRecord.journeyMapTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSeeMore,
                child: Row(
                  children: [
                    Text(
                      t.seeMore,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white60 : Colors.black45,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: Stack(
                children: [
                  _RecordJourneyPreviewMap(posts: posts),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onSeeMore,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordJourneyPreviewMap extends StatefulWidget {
  const _RecordJourneyPreviewMap({required this.posts});

  final List<Posts> posts;

  @override
  State<_RecordJourneyPreviewMap> createState() =>
      _RecordJourneyPreviewMapState();
}

class _RecordJourneyPreviewMapState extends State<_RecordJourneyPreviewMap> {
  static const _pinSourceId = 'fg_record_preview_pins';
  static const _glowLayerId = 'fg_record_preview_glow';
  static const _pinLayerId = 'fg_record_preview_dots';

  MapLibreMapController? _controller;
  bool _layersReady = false;

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  String _styleAsset(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == 'ja' ? Assets.map.earthJa : Assets.map.earthEn;
  }

  List<Posts> get _mappedPosts {
    return widget.posts
        .where((post) => post.lat != 0 && post.lng != 0)
        .toList();
  }

  Future<void> _renderOverlays() async {
    final controller = _controller;
    if (controller == null || _layersReady) {
      return;
    }
    try {
      final posts = _mappedPosts;
      await MapPrefectureFillLayer.render(
        controller,
        prefecturePostCounts: _collectPrefecturePostCounts(posts),
      );
      await _renderPins(controller, posts);
      await _fitCamera(controller, posts);
      _layersReady = true;
    } on Exception catch (e, st) {
      debugPrint('RecordJourneyPreviewMap overlay failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Map<String, int> _collectPrefecturePostCounts(List<Posts> posts) {
    final counts = <String, int>{};
    for (final post in posts) {
      final prefecture =
          PrefectureDetector.detectPrefecture(post.lat, post.lng);
      if (prefecture != null) {
        counts[prefecture] = (counts[prefecture] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<void> _renderPins(
    MapLibreMapController controller,
    List<Posts> posts,
  ) async {
    final features = _pinsByCountry(posts)
        .map(
          (pin) => {
            'type': 'Feature',
            'geometry': {
              'type': 'Point',
              'coordinates': [pin.lng, pin.lat],
            },
            'properties': <String, dynamic>{},
          },
        )
        .toList();

    try {
      await controller.removeLayer(_pinLayerId);
    } on Exception catch (_) {}
    try {
      await controller.removeLayer(_glowLayerId);
    } on Exception catch (_) {}
    try {
      await controller.removeSource(_pinSourceId);
    } on Exception catch (_) {}

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
      _glowLayerId,
      const CircleLayerProperties(
        circleRadius: 14,
        circleColor: '#93C5FD',
        circleOpacity: 0.28,
      ),
    );
    await controller.addCircleLayer(
      _pinSourceId,
      _pinLayerId,
      const CircleLayerProperties(
        circleRadius: 5,
        circleColor: '#2563EB',
        circleStrokeWidth: 1.6,
        circleStrokeColor: '#FFFFFF',
        circleOpacity: 0.95,
      ),
    );
  }

  Future<void> _fitCamera(
    MapLibreMapController controller,
    List<Posts> posts,
  ) async {
    const zoom = 0.4;
    if (posts.isEmpty) {
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: LatLng(20, 15),
            zoom: zoom,
          ),
        ),
      );
      return;
    }
    final pins = _pinsByCountry(posts);
    var focus = pins.first;
    for (final pin in pins) {
      if (pin.count > focus.count ||
          (pin.count == focus.count && pin.country == '日本')) {
        focus = pin;
      }
    }
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(focus.lat, focus.lng),
          zoom: zoom,
        ),
      ),
    );
  }

  /// 1カ国1ピン。位置はその国の投稿の平均座標
  List<_CountryPin> _pinsByCountry(List<Posts> posts) {
    final byCountry = <String, List<Posts>>{};
    for (final post in posts) {
      final country =
          CountryDetector.detectCountry(post.lat, post.lng) ?? 'その他';
      byCountry.putIfAbsent(country, () => []).add(post);
    }
    return byCountry.entries.map((entry) {
      var lat = 0.0;
      var lng = 0.0;
      for (final post in entry.value) {
        lat += post.lat;
        lng += post.lng;
      }
      final n = entry.value.length;
      return _CountryPin(
        country: entry.key,
        lat: lat / n,
        lng: lng / n,
        count: n,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString: _styleAsset(context),
      initialCameraPosition: const CameraPosition(
        target: LatLng(20, 15),
        zoom: 0.4,
      ),
      compassEnabled: false,
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: false,
      tiltGesturesEnabled: false,
      zoomGesturesEnabled: false,
      myLocationEnabled: false,
      onMapCreated: (controller) {
        _controller = controller;
      },
      onStyleLoadedCallback: () {
        _renderOverlays();
      },
    );
  }
}

class _CountryPin {
  const _CountryPin({
    required this.country,
    required this.lat,
    required this.lng,
    required this.count,
  });

  final String country;
  final double lat;
  final double lng;
  final int count;
}