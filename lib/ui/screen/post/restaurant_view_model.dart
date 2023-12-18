import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_gram_app/constants/api_key.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/post/restaurant_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'restaurant_view_model.g.dart';

@riverpod
class RestaurantViewModel extends _$RestaurantViewModel {
  @override
  RestaurantState build({
    RestaurantState initState = const RestaurantState(),
  }) {
    ref.onDispose(controller.dispose);
    _determinePosition();
    return initState;
  }

  final controller = TextEditingController();
  final androidKey = GoogleMapApiKey.androidKey;
  final iOSKey = GoogleMapApiKey.iOSKey;

  Loading get loading => ref.read(loadingProvider.notifier);

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(isApproval: false);
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(isApproval: false);
      }
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      state = state.copyWith(isApproval: true);
    }
    if (state.isApproval) {
      await _getInitialRestaurant();
    }
  }

  Future<void> _getInitialRestaurant() async {
    final position = await Geolocator.getCurrentPosition();
    final latitude = position.latitude;
    final longitude = position.longitude;
    loading.state = true;
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=1000&type=restaurant&key=${Platform.isIOS ? iOSKey : androidKey}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      state = state.copyWith(
        restaurant: List<String>.from(
          data['results'].map((restaurant) => restaurant['name']),
        ),
        address: List<String>.from(
          data['results'].map((restaurant) => restaurant['vicinity']),
        ),
        lat: List<double>.from(
          data['results']
              .map((restaurant) => restaurant['geometry']['location']['lat']),
        ),
        log: List<double>.from(
          data['results']
              .map((restaurant) => restaurant['geometry']['location']['lng']),
        ),
      );
      loading.state = false;
    } else {
      loading.state = false;
      logger.e(response.statusCode);
    }
  }

  Future<void> search(String value) async {
    clearList();
    if (value.isNotEmpty) {
      loading.state = true;
      state = state.copyWith(searchText: value);
      final query = value.toLowerCase();
      final pageToken = state.nextPageToken.isNotEmpty
          ? '&pagetoken=${state.nextPageToken}'
          : '';
      final url =
          'https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurant+$query&key=${Platform.isIOS ? iOSKey : androidKey}$pageToken';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        state = state.copyWith(
          restaurant: [
            ...state.restaurant,
            ...List<String>.from(
              data['results'].map(
                (restaurant) => restaurant['name'],
              ),
            ),
          ],
          address: [
            ...state.address,
            ...List<String>.from(
              data['results'].map(
                (restaurant) => restaurant['formatted_address'],
              ),
            ),
          ],
          lat: [
            ...state.lat,
            ...List<double>.from(
              data['results'].map(
                (restaurant) => restaurant['geometry']['location']['lat'],
              ),
            ),
          ],
          log: [
            ...state.log,
            ...List<double>.from(
              data['results'].map(
                (restaurant) => restaurant['geometry']['location']['lng'],
              ),
            ),
          ],
          nextPageToken: data['next_page_token'] ?? '',
        );
        loading.state = false;
      } else {
        loading.state = false;
        logger.e(response.statusCode);
      }
    } else {
      await _getInitialRestaurant();
    }
  }

  void clearList() {
    state = state.copyWith(
      restaurant: [],
      log: [],
      lat: [],
    );
  }
}
