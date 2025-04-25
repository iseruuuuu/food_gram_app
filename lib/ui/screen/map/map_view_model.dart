import 'package:flutter/services.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/component/app_pin_widget.dart';
import 'package:food_gram_app/ui/screen/map/map_state.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';

part 'map_view_model.g.dart';

@riverpod
class MapViewModel extends _$MapViewModel {
  @override
  MapState build() {
    return const MapState();
  }

  Future<void> setMapController(
    MapLibreMapController controller, {
    required void Function(List<Posts> posts) onPinTap,
    required double iconSize,
  }) async {
    state = state.copyWith(mapController: controller);
    await setPin(
      onPinTap: onPinTap,
      iconSize: iconSize,
    );
  }

  bool isInitialLoading = true;
  final screenshotController = ScreenshotController();

  Future<void> setPin({
    required void Function(List<Posts> posts) onPinTap,
    required double iconSize,
  }) async {
    if (!isInitialLoading) {
      await state.mapController!.clearSymbols();
    }
    try {
      final screenshotBytes = await screenshotController.captureFromWidget(
        AppPinWidget(image: Assets.image.pinIcon.path),
      );
      final list = screenshotBytes.buffer.asUint8List();
      await state.mapController!.addImage('pins', list);
      final symbols = <SymbolOptions>[];
      ref.read(mapRepositoryProvider).whenOrNull(
        data: (value) {
          for (var i = 0; i < value.length; i++) {
            symbols.add(
              SymbolOptions(
                geometry: LatLng(value[i].lat, value[i].lng),
                iconImage: 'pins',
                iconSize: iconSize,
              ),
            );
          }
        },
      );
      await state.mapController?.addSymbols(symbols);
      // 他のシンボルがアイコンに衝突した場合、表示されないようにする
      await state.mapController?.setSymbolIconIgnorePlacement(true);
      // アイコンは以前に描画された他のシンボルと衝突しても表示される。
      await state.mapController?.setSymbolIconAllowOverlap(true);
      state.mapController?.onSymbolTapped.add((symbol) async {
        state = state.copyWith(isLoading: true);
        final latLng = symbol.options.geometry;
        final lat = latLng!.latitude;
        final lng = latLng.longitude;
        final restaurant = await ref
            .read(postRepositoryProvider.notifier)
            .getRestaurantPosts(lat: lat, lng: lng);
        restaurant.whenOrNull(
          success: (posts) {
            onPinTap(posts);
          },
        );
        await state.mapController?.animateCamera(
          CameraUpdate.newLatLng(latLng),
          duration: const Duration(seconds: 1),
        );
        isInitialLoading = false;
        state = state.copyWith(
          isLoading: false,
          hasError: false,
        );
      });
    } on PlatformException catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
      );
    }
  }

  Future<void> setRamenPin({
    required void Function(List<Posts> posts) onPinTap,
    required double iconSize,
  }) async {
    await state.mapController!.clearSymbols();
    try {
      final screenshotBytes = await screenshotController.captureFromWidget(
        AppPinWidget(image: Assets.image.pinRamen.path),
      );
      final list = screenshotBytes.buffer.asUint8List();
      await state.mapController?.addImage('pin_ramen', list);
      final symbols = <SymbolOptions>[];
      final posts = await ref.watch(mapRamenRepositoryProvider.future);
      for (var i = 0; i < posts.length; i++) {
        symbols.add(
          SymbolOptions(
            geometry: LatLng(posts[i].lat, posts[i].lng),
            iconImage: 'pin_ramen',
            iconSize: iconSize,
          ),
        );
      }
      await state.mapController?.addSymbols(symbols);
      // 他のシンボルがアイコンに衝突した場合、表示されないようにする
      await state.mapController?.setSymbolIconIgnorePlacement(true);
      // アイコンは以前に描画された他のシンボルと衝突しても表示される。
      await state.mapController?.setSymbolIconAllowOverlap(true);
      state.mapController?.onSymbolTapped.add((symbol) async {
        state = state.copyWith(isLoading: true);
        final latLng = symbol.options.geometry;
        final lat = latLng!.latitude;
        final lng = latLng.longitude;
        final restaurant = await ref
            .read(postRepositoryProvider.notifier)
            .getRestaurantPosts(lat: lat, lng: lng);
        restaurant.whenOrNull(
          success: (posts) {
            onPinTap(posts);
          },
        );
        await state.mapController?.animateCamera(
          CameraUpdate.newLatLng(latLng),
          duration: const Duration(seconds: 1),
        );
        state = state.copyWith(
          isLoading: false,
          hasError: false,
        );
      });
    } on PlatformException catch (_) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
      );
    }
  }

  Future<void> moveToCurrentLocation() async {
    final currentLocation = ref.read(locationProvider);
    await currentLocation.whenOrNull(
      data: (location) async {
        final currentLatLng = LatLng(
          location.latitude,
          location.longitude,
        );
        await state.mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(currentLatLng, 16),
        );
      },
    );
  }
}
