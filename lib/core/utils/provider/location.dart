import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location.g.dart';

@Riverpod(keepAlive: true)
Future<LatLng> location(Ref ref) async {
  return getLocation();
}

@Riverpod(keepAlive: true)
Future<bool> isLocationEnabled(Ref ref) async {
  final permission = await Geolocator.checkPermission();
  return permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;
}

Future<LatLng> getLocation() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return const LatLng(0, 0);
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return const LatLng(0, 0);
    }
  }
  if (permission != LocationPermission.whileInUse &&
      permission != LocationPermission.always) {
    return const LatLng(0, 0);
  }

  // 高精度GPS待ちで起動が止まらないよう、前回位置があればそれを使う
  final last = await Geolocator.getLastKnownPosition();
  if (last != null) {
    return LatLng(last.latitude, last.longitude);
  }

  try {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 4),
    );
    return LatLng(position.latitude, position.longitude);
  } on TimeoutException {
    return const LatLng(0, 0);
  }
}
