import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/summary/summary_launch_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

Posts _post(DateTime createdAt) => Posts(
      id: 1,
      foodImage: 'user/food.jpg',
      foodName: 'Food',
      restaurant: '店',
      comment: '',
      createdAt: createdAt,
      lat: 0,
      lng: 0,
      userId: 'user',
      heart: 0,
      star: 4,
      foodTag: '',
      isAnonymous: false,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('resolveSummaryLaunch', () {
    test('1日は月間を優先し、週間は返さない', () async {
      final result = await resolveSummaryLaunch(
        now: DateTime(2026, 8),
        posts: [_post(DateTime(2026, 7, 15))],
      );
      expect(result, SummaryLaunchType.monthly);
    });

    test('1日でも先月投稿がなければ何も出さない', () async {
      final result = await resolveSummaryLaunch(
        now: DateTime(2026, 8),
        posts: [_post(DateTime(2026, 6, 15))],
      );
      expect(result, isNull);
    });

    test('1日以外は週間のみ判定する', () async {
      // 2026-07-13 は月曜 → 先週は 7/6〜7/12
      final result = await resolveSummaryLaunch(
        now: DateTime(2026, 7, 13),
        posts: [_post(DateTime(2026, 7, 8))],
      );
      expect(result, SummaryLaunchType.weekly);
    });
  });
}
