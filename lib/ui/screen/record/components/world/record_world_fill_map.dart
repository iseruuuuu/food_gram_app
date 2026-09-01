import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/location/country_display.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/screen/map/components/map_country_fill_layer.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// 記録タブ：訪れた国を塗りつぶした世界地図
class RecordWorldFillMap extends StatefulWidget {
  const RecordWorldFillMap({
    required this.posts,
    this.interactive = false,
    super.key,
  });

  final List<Posts> posts;
  final bool interactive;

  @override
  State<RecordWorldFillMap> createState() => _RecordWorldFillMapState();
}

class _RecordWorldFillMapState extends State<RecordWorldFillMap> {
  static const _worldCamera = CameraPosition(target: LatLng(20, 10));

  MapLibreMapController? _controller;
  bool _layersReady = false;

  @override
  void didUpdateWidget(covariant RecordWorldFillMap oldWidget) {
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

  String _styleAsset(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return lang == 'ja' ? Assets.map.localJa : Assets.map.localEn;
  }

  Future<void> _renderOverlays() async {
    final controller = _controller;
    if (controller == null || _layersReady) {
      return;
    }
    try {
      await MapCountryFillLayer.render(
        controller,
        countryPostCounts: recordCountryPostCounts(widget.posts),
      );
      await controller.moveCamera(CameraUpdate.newCameraPosition(_worldCamera));
      _layersReady = true;
    } on Exception catch (e, st) {
      debugPrint('RecordWorldFillMap overlay failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapLibreMap(
      styleString: _styleAsset(context),
      initialCameraPosition: _worldCamera,
      minMaxZoomPreference: const MinMaxZoomPreference(0, 6),
      compassEnabled: false,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      scrollGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      gestureRecognizers: widget.interactive
          ? const {
              Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
            }
          : const <Factory<OneSequenceGestureRecognizer>>{},
      onMapCreated: (controller) {
        _controller = controller;
      },
      onStyleLoadedCallback: _renderOverlays,
    );
  }
}
