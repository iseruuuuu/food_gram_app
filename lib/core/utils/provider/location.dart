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
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return const LatLng(0, 0);
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return const LatLng(0, 0);
    }
  }
  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    final position = await Geolocator.getCurrentPosition();
    final latitude = position.latitude;
    final longitude = position.longitude;
    return LatLng(latitude, longitude);
  }
  return const LatLng(0, 0);
}
