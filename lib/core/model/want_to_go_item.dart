import 'dart:convert';

import 'package:food_gram_app/core/model/restaurant.dart';

class WantToGoItem {
  const WantToGoItem({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.addedAt,
  });

  factory WantToGoItem.fromRestaurant(Restaurant restaurant) {
    return WantToGoItem(
      name: restaurant.name,
      address: restaurant.address,
      lat: restaurant.lat,
      lng: restaurant.lng,
      addedAt: DateTime.now(),
    );
  }

  factory WantToGoItem.fromJson(Map<String, dynamic> json) {
    return WantToGoItem(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// 旧形式（店名のみの StringList）からの移行用
  factory WantToGoItem.fromLegacyName(String name) {
    return WantToGoItem(
      name: name,
      address: '',
      lat: 0,
      lng: 0,
      addedAt: DateTime.now(),
    );
  }

  final String name;
  final String address;
  final double lat;
  final double lng;
  final DateTime addedAt;

  bool get hasLocation => lat != 0 || lng != 0;

  Restaurant toRestaurant() => Restaurant(
        name: name,
        address: address,
        lat: lat,
        lng: lng,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'lat': lat,
        'lng': lng,
        'addedAt': addedAt.toIso8601String(),
      };
}

class WantToGoStore {
  const WantToGoStore(this.items);

  factory WantToGoStore.fromJsonString(String raw) {
    if (raw.isEmpty) {
      return const WantToGoStore([]);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const WantToGoStore([]);
      }
      final items = <WantToGoItem>[];
      for (final e in decoded) {
        if (e is Map<String, dynamic>) {
          items.add(WantToGoItem.fromJson(e));
        } else if (e is Map) {
          items.add(WantToGoItem.fromJson(Map<String, dynamic>.from(e)));
        } else if (e is String && e.trim().isNotEmpty) {
          items.add(WantToGoItem.fromLegacyName(e.trim()));
        }
      }
      return WantToGoStore(items);
    } on Object {
      return const WantToGoStore([]);
    }
  }

  final List<WantToGoItem> items;

  String toJsonString() => jsonEncode(items.map((e) => e.toJson()).toList());
}
