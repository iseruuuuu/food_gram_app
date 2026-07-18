import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/summary/monthly/monthly_summary_calculator.dart';
import 'package:food_gram_app/core/summary/monthly/monthly_summary_period.dart';
import 'package:food_gram_app/ui/screen/summary/monthly/monthly_summary_screen.dart';

Posts _post({
  required int id,
  required DateTime createdAt,
  String restaurant = '店A',
  double star = 4,
  String foodTag = '',
  double lat = 0,
  double lng = 0,
}) =>
    Posts(
      id: id,
      foodImage: 'user/food.jpg',
      foodName: 'Food $id',
      restaurant: restaurant,
      comment: '',
      createdAt: createdAt,
      lat: lat,
      lng: lng,
      userId: 'user',
      heart: 0,
      star: star,
      foodTag: foodTag,
      isAnonymous: false,
    );

void main() {
  test('月間まとめ画面を構築できる', () {
    expect(const MonthlySummaryScreen(), isA<MonthlySummaryScreen>());
  });

  group('MonthlySummaryPeriod', () {
    test('年をまたいだ先月を返す', () {
      final period = MonthlySummaryPeriod.previousMonth(
        DateTime(2027),
      );
      expect(period.monthStart, DateTime(2026, 12));
      expect(period.monthEndExclusive, DateTime(2027));
      expect(period.monthEndInclusive, DateTime(2026, 12, 31));
      expect(period.preferenceKey, '2026-12');
    });

    test('contains は月境界を正しく判定する', () {
      final period = MonthlySummaryPeriod.previousMonth(
        DateTime(2026, 8),
      );
      expect(period.contains(DateTime(2026, 7)), isTrue);
      expect(period.contains(DateTime(2026, 7, 31, 23, 59)), isTrue);
      expect(period.contains(DateTime(2026, 6, 30, 23, 59)), isFalse);
      expect(period.contains(DateTime(2026, 8)), isFalse);
    });
  });

  test('当月と前月を比較し、ジャンルTOP3を集計する', () {
    final period = MonthlySummaryPeriod.previousMonth(DateTime(2026, 8));
    final posts = [
      _post(id: 1, createdAt: DateTime(2026, 5), restaurant: '既存店'),
      _post(
        id: 2,
        createdAt: DateTime(2026, 6, 2),
        restaurant: '前月新店',
        star: 3,
        foodTag: '🍕',
      ),
      _post(
        id: 3,
        createdAt: DateTime(2026, 7, 2),
        restaurant: '既存店',
        foodTag: '🍜',
      ),
      _post(
        id: 4,
        createdAt: DateTime(2026, 7, 8),
        restaurant: '今月新店',
        star: 5,
        foodTag: '🍜,🍰',
      ),
    ];

    final summary = calculateMonthlySummary(
      allPosts: posts,
      period: period,
    );

    expect(summary.postCount, 2);
    expect(summary.previousPostCount, 1);
    expect(summary.newRestaurantCount, 1);
    expect(summary.previousNewRestaurantCount, 1);
    expect(summary.averageStar, 4.5);
    expect(summary.previousAverageStar, 3);
    expect(summary.topGenres.first.tagId, '🍜');
    expect(summary.topGenres.first.count, 2);
  });

  test('累積訪問と今月新規の都道府県・国を集計する', () {
    final period = MonthlySummaryPeriod.previousMonth(DateTime(2026, 8));
    // 東京: 35.689, 139.692 / 神奈川: 35.448, 139.642 / 台湾: 25.0, 121.5
    final posts = [
      _post(
        id: 1,
        createdAt: DateTime(2026, 5, 10),
        lat: 35.689,
        lng: 139.692,
      ),
      _post(
        id: 2,
        createdAt: DateTime(2026, 7, 5),
        lat: 35.448,
        lng: 139.642,
      ),
      _post(
        id: 3,
        createdAt: DateTime(2026, 7, 12),
        lat: 25,
        lng: 121.5,
      ),
    ];

    final summary = calculateMonthlySummary(
      allPosts: posts,
      period: period,
    );

    expect(summary.visitedPrefectures, containsAll(['東京都', '神奈川県']));
    expect(summary.newPrefecturesThisMonth, ['神奈川県']);
    expect(summary.visitedCountries, ['台湾']);
    expect(summary.newCountriesThisMonth, ['台湾']);
  });
}
