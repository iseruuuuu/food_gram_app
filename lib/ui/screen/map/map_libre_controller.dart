import 'package:flutter/services.dart';
import 'package:food_gram_app/core/data/supabase/map_service.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_libre_controller.g.dart';

@Riverpod(keepAlive: true)
class MapLibreController extends _$MapLibreController {
  @override
  void build() {}

  late MapLibreMapController controller;

  Future<void> setPin({
    required void Function(List<Posts> post) openDialog,
  }) async {
    final bytes = await rootBundle.load(Assets.image.pin.path);
    final list = bytes.buffer.asUint8List();
    await controller.addImage('pin', list);
    final symbols = <SymbolOptions>[];
    ref.read(mapServiceProvider).whenOrNull(
      data: (value) {
        for (var i = 0; i < value.length; i++) {
          symbols.add(
            SymbolOptions(
              geometry: LatLng(value[i].lat, value[i].lng),
              iconImage: 'pin',
              iconSize: 0.2,
            ),
          );
        }
      },
    );
    await controller.addSymbols(symbols);
    controller.onSymbolTapped.add((symbol) async {
      final latLng = symbol.options.geometry;
      final lat = latLng!.latitude;
      final lng = latLng.longitude;

      print(latLng);
      print(lng);

      await ref
          .read(getRestaurantProvider(point: LatLng(lat, lng)).future)
          .then((result) {
        //TODO 投稿内容が取得できていない・・？
        print(result);
        openDialog(result);
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 16.5),
          duration: Duration(seconds: 2),
        );
      });
    });
  }
}
