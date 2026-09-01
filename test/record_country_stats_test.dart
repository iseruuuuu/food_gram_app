import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/utils/location/country_display.dart';

Posts _post({
  required int id,
  required DateTime createdAt,
  required double lat,
  required double lng,
}) =>
    Posts(
      id: id,
      foodImage: 'user/food.jpg',
      foodName: 'Food $id',
      restaurant: '店',
      comment: '',
      createdAt: createdAt,
      lat: lat,
      lng: lng,
      userId: 'user',
      heart: 0,
      star: 4,
      foodTag: '',
      isAnonymous: false,
    );

void main() {
  group('recordVisitedCountryStats', () {
    test('国ごとに投稿数を集計し、最近訪れた順にする', () {
      final stats = recordVisitedCountryStats([
        _post(
          id: 1,
          createdAt: DateTime(2026),
          lat: 35.68,
          lng: 139.76,
        ),
        _post(
          id: 2,
          createdAt: DateTime(2026, 3),
          lat: 35.68,
          lng: 139.76,
        ),
        _post(
          id: 3,
          createdAt: DateTime(2026, 2),
          lat: 40.71,
          lng: -74.01,
        ),
        _post(
          id: 4,
          createdAt: DateTime(2026, 4),
          lat: 25.03,
          lng: 121.56,
        ),
      ]);

      expect(stats.map((visit) => visit.code).toList(), ['TW', 'JP', 'US']);
      expect(stats.first.postCount, 1);
      expect(stats[1].code, 'JP');
      expect(stats[1].postCount, 2);
    });

    test('座標がない投稿は集計しない', () {
      final stats = recordVisitedCountryStats([
        _post(
          id: 1,
          createdAt: DateTime(2026),
          lat: 0,
          lng: 0,
        ),
      ]);
      expect(stats, isEmpty);
    });
  });

  test('countryFlagEmoji は ISO コードから旗を作る', () {
    expect(countryFlagEmoji('JP'), '🇯🇵');
    expect(countryFlagEmoji('US'), '🇺🇸');
  });
}
