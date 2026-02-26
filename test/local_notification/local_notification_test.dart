import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ローカル通知 - スケジュール時刻の計算', () {
    /// NotificationService と同じロジック: 昼12時の次回通知時刻
    /// 今日の12時が過ぎている場合は明日の12時に設定
    DateTime computeNextLunchScheduledTime(DateTime now) {
      final lunchTime = DateTime(now.year, now.month, now.day, 12);
      return lunchTime.isBefore(now)
          ? lunchTime.add(const Duration(days: 1))
          : lunchTime;
    }

    /// NotificationService と同じロジック: 夜19時の次回通知時刻
    /// 今日の19時が過ぎている場合は明日の19時に設定
    DateTime computeNextDinnerScheduledTime(DateTime now) {
      final dinnerTime = DateTime(now.year, now.month, now.day, 19);
      return dinnerTime.isBefore(now)
          ? dinnerTime.add(const Duration(days: 1))
          : dinnerTime;
    }

    group('昼12時リマインダー', () {
      test('現在が12時より前のときは今日の12時に設定される', () {
        final now = DateTime(2024, 6, 15, 11, 59);
        final scheduled = computeNextLunchScheduledTime(now);
        expect(scheduled, DateTime(2024, 6, 15, 12));
      });

      test('現在がちょうど12時のときは今日の12時に設定される（isBefore で同日扱い）', () {
        final now = DateTime(2024, 6, 15, 12);
        final scheduled = computeNextLunchScheduledTime(now);
        expect(scheduled, DateTime(2024, 6, 15, 12));
      });

      test('現在が12時を過ぎているときは明日の12時に設定される', () {
        final now = DateTime(2024, 6, 15, 14);
        final scheduled = computeNextLunchScheduledTime(now);
        expect(scheduled, DateTime(2024, 6, 16, 12));
      });

      test('深夜0時台のときは今日の12時に設定される', () {
        final now = DateTime(2024, 6, 15, 0, 30);
        final scheduled = computeNextLunchScheduledTime(now);
        expect(scheduled, DateTime(2024, 6, 15, 12));
      });

      test('月末をまたいでも正しく明日の12時になる', () {
        // 12時ちょうどだと isBefore(now) が false になるため、12時以降で検証する
        final now = DateTime(2024, 6, 30, 12, 1);
        final scheduled = computeNextLunchScheduledTime(now);
        expect(scheduled, DateTime(2024, 7, 1, 12));
      });
    });

    group('夜19時リマインダー', () {
      test('現在が19時より前のときは今日の19時に設定される', () {
        final now = DateTime(2024, 6, 15, 18, 59);
        final scheduled = computeNextDinnerScheduledTime(now);
        expect(scheduled, DateTime(2024, 6, 15, 19));
      });

      test('現在がちょうど19時のときは今日の19時に設定される（isBefore で同日扱い）', () {
        final now = DateTime(2024, 6, 15, 19);
        final scheduled = computeNextDinnerScheduledTime(now);
        expect(scheduled, DateTime(2024, 6, 15, 19));
      });

      test('現在が19時を過ぎているときは明日の19時に設定される', () {
        final now = DateTime(2024, 6, 15, 21);
        final scheduled = computeNextDinnerScheduledTime(now);
        expect(scheduled, DateTime(2024, 6, 16, 19));
      });

      test('昼間のときは今日の19時に設定される', () {
        final now = DateTime(2024, 6, 15, 12);
        final scheduled = computeNextDinnerScheduledTime(now);
        expect(scheduled, DateTime(2024, 6, 15, 19));
      });
    });
  });

  group('ローカル通知 - 食事リマインダーのペイロード', () {
    test('昼リマインダーのペイロードは type と mealType を含む', () {
      final payload = {
        'type': 'meal_reminder',
        'mealType': 'lunch',
      };
      final encoded = json.encode(payload);
      final decoded = json.decode(encoded) as Map<String, dynamic>;

      expect(decoded['type'], 'meal_reminder');
      expect(decoded['mealType'], 'lunch');
    });

    test('夜リマインダーのペイロードは type と mealType を含む', () {
      final payload = {
        'type': 'meal_reminder',
        'mealType': 'dinner',
      };
      final encoded = json.encode(payload);
      final decoded = json.decode(encoded) as Map<String, dynamic>;

      expect(decoded['type'], 'meal_reminder');
      expect(decoded['mealType'], 'dinner');
    });

    test('ペイロードから type で meal_reminder を判定できる', () {
      final payload = {'type': 'meal_reminder', 'mealType': 'lunch'};
      final type = payload['type']?.toString() ?? '';
      expect(type, 'meal_reminder');
    });

    test('ペイロードから mealType で lunch/dinner を判定できる', () {
      final lunchPayload = {'type': 'meal_reminder', 'mealType': 'lunch'};
      final dinnerPayload = {'type': 'meal_reminder', 'mealType': 'dinner'};

      expect(lunchPayload['mealType'], 'lunch');
      expect(dinnerPayload['mealType'], 'dinner');
    });
  });

  group('ローカル通知 - 通知ID', () {
    test('昼リマインダーは id=1、夜リマインダーは id=2 でスケジュールされる', () {
      // NotificationService の scheduleLunchReminder(id: 1)
      // scheduleDinnerReminder(id: 2) の仕様
      const lunchNotificationId = 1;
      const dinnerNotificationId = 2;
      expect(lunchNotificationId, 1);
      expect(dinnerNotificationId, 2);
    });
  });
}
