import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Heart Limit Tests', () {
    late Preference preference;

    setUp(() {
      // 毎回モックを空の状態で初期化
      SharedPreferences.setMockInitialValues({});
      preference = Preference();
    });

    tearDown(() async {
      // テスト後にデータをクリア
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('heartCount');
      await prefs.remove('heartDate');
    });

    test('初期状態ではいいねが可能', () async {
      final canLike = await preference.canLike();
      expect(canLike, isTrue);
    });

    test('10回いいねを付けると制限に達する', () async {
      // 10回いいねを付ける
      for (var i = 0; i < 10; i++) {
        await preference.incrementHeartCount();
      }
      final canLike = await preference.canLike();
      expect(canLike, isFalse); // 10回いいねを付けた後は制限に達するのでfalse
    });

    test('11回目はいいねができない', () async {
      // 10回いいねを付ける
      for (var i = 0; i < 10; i++) {
        await preference.incrementHeartCount();
      }

      // 11回目を試行
      final canLike = await preference.canLike();
      expect(canLike, isFalse);
    });

    test('日付が変わるとカウントがリセットされる', () async {
      // 今日の日付を設定
      final today = DateTime.now().toIso8601String().split('T')[0];
      await preference.setString(PreferenceKey.heartDate, today);
      await preference.setInt(PreferenceKey.heartCount, 5);

      // 昨日の日付に変更
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .split('T')[0];
      await preference.setString(PreferenceKey.heartDate, yesterday);

      // canLikeを呼び出すと日付がリセットされる
      final canLike = await preference.canLike();
      expect(canLike, isTrue);
    });

    test('9回まではいいねが可能', () async {
      // 9回いいねを付ける
      for (var i = 0; i < 9; i++) {
        await preference.incrementHeartCount();
      }

      final canLike = await preference.canLike();
      expect(canLike, isTrue);
    });

    test('前のテストの影響を受けない', () async {
      // 前のテストで設定された値がないことを確認
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('heartCount'), isNull);
      expect(prefs.getString('heartDate'), isNull);

      // 初期状態ではいいねが可能
      final canLike = await preference.canLike();
      expect(canLike, isTrue);
    });

    test('特定の初期値でテスト', () async {
      // 特定の初期値を設定
      SharedPreferences.setMockInitialValues({
        'heartCount': 5,
        'heartDate': '2024-01-01',
      });

      final newPreference = Preference();
      final canLike = await newPreference.canLike();
      expect(canLike, isTrue); // 5回なのでまだいいね可能
    });
  });
}
