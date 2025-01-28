import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/core/data/supabase/service/posts_service.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/location.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'maplibre_provider.g.dart';

@Riverpod(keepAlive: true)
class MapLibre extends _$MapLibre {
  @override
  void build() {}

  late MapLibreMapController controller;

  Future<void> setPin({
    required void Function(List<Posts> post) openDialog,
    required BuildContext context,
  }) async {
    final bytes = await rootBundle.load(Assets.image.pin.path);
    final list = bytes.buffer.asUint8List();
    await controller.addImage('pin', list);
    final symbols = <SymbolOptions>[];
    final iconSize = _calculateIconSize(context);
    ref.read(mapServiceProvider).whenOrNull(
      data: (value) {
        for (var i = 0; i < value.length; i++) {
          symbols.add(
            SymbolOptions(
              geometry: LatLng(value[i].lat, value[i].lng),
              iconImage: 'pin',
              iconSize: iconSize,
            ),
          );
        }
      },
    );
    await controller.addSymbols(symbols);
    await controller.setSymbolIconAllowOverlap(true);
    controller.onSymbolTapped.add((symbol) async {
      final latLng = symbol.options.geometry;
      final lat = latLng!.latitude;
      final lng = latLng.longitude;
      final result =
          await ref.read(getRestaurantProvider(lat: lat, lng: lng).future);
      openDialog(result);
      await controller.animateCamera(
        CameraUpdate.newLatLng(latLng),
        duration: Duration(seconds: 1),
      );
    });
  }

  Future<void> moveToCurrentLocation() async {
    final currentLocation = ref.read(locationProvider);
    await currentLocation.whenOrNull(
      data: (location) async {
        final currentLatLng = LatLng(
          location.latitude,
          location.longitude,
        );
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(currentLatLng, 14),
        );
      },
    );
  }
}

double _calculateIconSize(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth <= 375) {
    return 0.4;
  } else if (screenWidth < 720) {
    return 0.6;
  } else {
    return 0.8;
  }
}
