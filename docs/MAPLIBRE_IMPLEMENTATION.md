# MapLibre Implementation Guide

This document explains how MapLibre GL is implemented and used in Food Gram App.

## Overview

Food Gram uses the `maplibre_gl` package to implement interactive map functionality. Post location information is displayed on the map, allowing users to discover posts.

## Technology Stack

- **maplibre_gl**: 0.24.1
- **geolocator**: Location services
- **screenshot**: Pin image generation

## Architecture

### Directory Structure

```
lib/
├── ui/screen/map/
│   ├── map_screen.dart          # Map screen
│   ├── map_view_model.dart      # Map state management
│   └── map_state.dart           # Map state definition
├── core/supabase/post/
│   ├── repository/
│   │   └── map_post_repository.dart  # Map post repository
│   └── services/
│       └── map_post_service.dart     # Map post service
└── ui/component/
    └── app_pin_widget.dart      # Pin widget
```

## Key Features

### 1. Map Display

#### Map Initialization

```dart
MapLibreMap(
  onMapCreated: (mapLibre) {
    controller.setMapController(
      mapLibre,
      onPinTap: (posts) {
        // Handle pin tap
      },
      iconSize: _calculateIconSize(context),
    );
  },
  initialCameraPosition: CameraPosition(
    target: isLocationEnabled ? currentLocation : defaultLocation,
    zoom: isLocationEnabled ? 16 : 3.8,
  ),
  styleString: _localizedStyleAsset(context, isEarthStyle),
)
```

#### Map Styles

- **Local Style**: Standard map style (`local_ja.json`, `local_en.json`)
- **Earth Style**: Globe style (`earth_ja.json`, `earth_en.json`)
- Earth style is only available for premium members

### 2. Pin Display

#### Pin Image Generation

Pin images are dynamically generated based on the post's `foodTag`:

1. **Default Image Pre-generation**: Generate default pin image on app startup
2. **Tag-based Image Generation**: Generate pin images according to post's `foodTag`
3. **Image Caching**: Cache generated images for reuse

```dart
Future<Map<String, String>> _generatePinImages(
  Set<String> imageTypes,
  List<Posts> posts,
) async {
  // Generate images in parallel
  // Reuse if cached
  // Add images to map
}
```

#### Pin Placement

Create symbols (pins) from post data and add them to the map:

```dart
final symbols = posts.map((post) {
  final imageType = post.foodTag.isEmpty
      ? 'default'
      : post.foodTag.split(',').first.trim();
  return SymbolOptions(
    geometry: LatLng(post.lat, post.lng),
    iconImage: imageKeys[imageType],
    iconSize: iconSize,
  );
}).toList();
```


### 3. Pin Tap Functionality

#### Tap Event Handling

When a pin is tapped, fetch the post list at that location and display a modal sheet:

```dart
state.mapController?.onSymbolTapped.add((symbol) async {
  final latLng = symbol.options.geometry;
  final restaurant = await ref
      .read(mapPostRepositoryProvider.notifier)
      .getRestaurantPosts(lat: latLng!.latitude, lng: latLng.longitude);
  restaurant.whenOrNull(success: (posts) => onPinTap(posts));
  // Animate camera
  await state.mapController?.animateCamera(
    CameraUpdate.newLatLng(latLng),
    duration: const Duration(seconds: 1),
  );
});
```

### 4. Location Services

#### Getting Current Location

Use `geolocator` to get the current location:

```dart
final location = ref.watch(locationProvider);
```

#### Moving to Current Location

When the current location button is tapped, move the camera to the current location:

```dart
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
```

### 5. Map Style Switching

#### Style Switching Process

When switching styles, clear image registration information and re-register:

```dart
void handleStyleChange() {
  // Clear image registration when style changes
  _registeredImageKeys.clear();
}

void onStyleLoaded() {
  // Restore pins after style loads
  if (_cachedPosts != null) {
    _restorePinsFromCache();
  }
}
```

## Reference Links

- [MapLibre GL JS Documentation](https://maplibre.org/maplibre-gl-js-docs/)
- [maplibre_gl Flutter Package](https://pub.dev/packages/maplibre_gl)
- [geolocator Package](https://pub.dev/packages/geolocator)

