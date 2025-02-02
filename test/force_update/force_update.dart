import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/local/force_update_checker.dart';

void main() {
  late ForceUpdateChecker forceUpdateChecker;

  setUp(() {
    forceUpdateChecker = ForceUpdateChecker();
  });

  group('shouldForceUpdate Tests', () {
    test('should return true when major version is different', () {
      // メジャーバージョンが異なる場合
      final result = forceUpdateChecker.shouldForceUpdate('1.0.0', '2.0.0');
      expect(result, isTrue); // 強制アップデートが必要
    });

    test('should return true when minor version is different', () {
      // メジャーバージョンは同じで、マイナーバージョンが異なる場合
      final result = forceUpdateChecker.shouldForceUpdate('1.1.0', '1.2.0');
      expect(result, isTrue); // 強制アップデートが必要
    });

    test('should return true when patch version is different', () {
      // メジャーバージョン、マイナーバージョンは同じで、パッチバージョンが異なる場合
      final result = forceUpdateChecker.shouldForceUpdate('1.0.1', '1.0.2');
      expect(result, isFalse); // アップデートは不要
    });

    test('should return false when versions are identical', () {
      // バージョンが同じ場合
      final result = forceUpdateChecker.shouldForceUpdate('1.0.0', '1.0.0');
      expect(result, isFalse); // アップデートは不要
    });

    test('should return false when current version is greater', () {
      // 現在のバージョンがストアのバージョンより大きい場合
      final result = forceUpdateChecker.shouldForceUpdate('2.0.0', '1.0.0');
      expect(result, isFalse); // 強制アップデートは不要
    });

    test('should return false when version format is incorrect', () {
      // バージョン形式が不正な場合
      final result = forceUpdateChecker.shouldForceUpdate('1.0', '1.0.0');
      expect(result, isFalse); // アップデートは不要
    });
  });
}
