import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_gram_app/constants/api_key.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/post/restaurant_state.dart';
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
    _getInitialRestaurant();
    return initState;
  }

  final controller = TextEditingController();
  final androidKey = GoogleMapApiKey.androidKey;
  final iOSKey = GoogleMapApiKey.iOSKey;

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //TODO  位置情報サービスを有効にするようアプリに要請する。
      state = state.copyWith(isApproval: false);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        //TODO  位置情報サービスを有効にするようアプリに要請する。
        state = state.copyWith(isApproval: false);
      }
    }
  }

  Future<void> _getInitialRestaurant() async {
    final position = await Geolocator.getCurrentPosition();
    final latitude = position.latitude;
    final longitude = position.longitude;
    late String url;
    //TODO あとでいい感じに修正する
    if (Platform.isIOS) {
      url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=1000&type=restaurant&key=$iOSKey';
    } else {
      //TODO Androidでちゃんとできるか確認をする

      url =
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=1000&type=restaurant&key=$androidKey';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //TODO Androidだとエラーになる
      //error_message: This API key is not authorized to use this service or API., html_attributions: [], results: [], status: REQUEST_DENIED
      state = state.copyWith(
        restaurant: List<String>.from(
          data['results'].map((restaurant) => restaurant['name']),
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
    } else {
      logger.e(response.statusCode);
    }
  }

  Future<void> search(String value) async {
    state = state.copyWith(searchText: value);
    final query = value.toLowerCase();
    final position = await Geolocator.getCurrentPosition();
    final latitude = position.latitude;
    final longitude = position.longitude;
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=$latitude,$longitude&radius=1000&key=${Platform.isIOS ? iOSKey : androidKey}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //TODO Androidだとエラーになる
      //error_message: This API key is not authorized to use this service or API., html_attributions: [], results: [], status: REQUEST_DENIED
      state = state.copyWith(
        restaurant: List<String>.from(
          data['results'].map((restaurant) => restaurant['name']),
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
    } else {
      logger.e(response.statusCode);
    }
  }
}