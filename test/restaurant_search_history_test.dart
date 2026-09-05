import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/restaurant_search_history.dart';

void main() {
  const ramen = Restaurant(
    name: 'Ramen Shop',
    address: 'Tokyo',
    lat: 35.681236,
    lng: 139.767125,
  );
  const cafe = Restaurant(
    name: 'Cafe',
    address: 'Osaka',
    lat: 34.702485,
    lng: 135.495951,
  );
  const unknown = Restaurant(
    name: unknownRestaurantName,
    address: '',
    lat: 0,
    lng: 0,
  );

  group('RestaurantSearchHistoryStore', () {
    test('add puts the latest restaurant first and drops duplicates', () {
      final store = const RestaurantSearchHistoryStore([])
          .add(ramen)
          .add(cafe)
          .add(
            ramen.copyWith(address: 'Updated'),
          );

      expect(store.items, hasLength(2));
      expect(store.items.first.name, 'Ramen Shop');
      expect(store.items.first.address, 'Updated');
      expect(store.items.last.name, 'Cafe');
    });

    test('add ignores unknown and empty-name restaurants', () {
      const emptyName = Restaurant(name: '  ', address: 'x', lat: 1, lng: 1);
      final store = const RestaurantSearchHistoryStore([])
          .add(unknown)
          .add(emptyName);

      expect(store.items, isEmpty);
    });

    test('add keeps at most maxItems', () {
      var store = const RestaurantSearchHistoryStore([]);
      for (var i = 0; i < RestaurantSearchHistoryStore.maxItems + 5; i++) {
        store = store.add(
          Restaurant(
            name: 'Shop $i',
            address: 'Address $i',
            lat: i.toDouble(),
            lng: i.toDouble(),
          ),
        );
      }

      expect(store.items, hasLength(RestaurantSearchHistoryStore.maxItems));
      expect(store.items.first.name, 'Shop 24');
      expect(store.items.last.name, 'Shop 5');
    });

    test('remove deletes the matching restaurant', () {
      final store = const RestaurantSearchHistoryStore([])
          .add(ramen)
          .add(cafe)
          .remove(ramen);

      expect(store.items, [cafe]);
    });

    test('json round-trip preserves restaurants', () {
      final original =
          const RestaurantSearchHistoryStore([]).add(ramen).add(cafe);
      final restored =
          RestaurantSearchHistoryStore.fromJsonString(original.toJsonString());

      expect(restored.items, original.items);
    });

    test('fromJsonString returns empty on invalid json', () {
      expect(
        RestaurantSearchHistoryStore.fromJsonString('not-json').items,
        isEmpty,
      );
      expect(RestaurantSearchHistoryStore.fromJsonString('').items, isEmpty);
    });
  });
}
