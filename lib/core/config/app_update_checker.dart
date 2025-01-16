import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_update_checker.g.dart';

@riverpod
class AppUpdateChecker extends _$AppUpdateChecker {
  @override
  void build() {}

  Future<void> checkForceUpdate({required Function() openDialog}) async {
    // 現在のバージョンを取得
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    // Apple Storeの最新版のバージョンを取得
    final newVersion = NewVersionPlus();
    final status = await newVersion.getVersionStatus();

    if (status == null) {
      return; // ストア情報が取得できない場合、強制アップデートはしない
    }
    final storeVersion = status.storeVersion;
    // メジャー・マイナーバージョンの変化を確認
    final result = shouldForceUpdate(currentVersion, storeVersion);
    if (result) {
      openDialog();
    }
  }

  /// メジャーまたはマイナーバージョンに変化があるかを確認
  bool shouldForceUpdate(String currentVersion, String storeVersion) {
    try {
      // バージョンを分割して取得
      final currentParts = currentVersion.split('.');
      final storeParts = storeVersion.split('.');

      if (currentParts.length < 2 || storeParts.length < 2) {
        return false; // バージョン形式が不正の場合
      }

      // メジャーバージョンとマイナーバージョンを比較
      final currentMajor = int.parse(currentParts[0]);
      final currentMinor = int.parse(currentParts[1]);
      final storeMajor = int.parse(storeParts[0]);
      final storeMinor = int.parse(storeParts[1]);

      // メジャーまたはマイナーバージョンが異なる場合は強制アップデート
      return currentMajor < storeMajor ||
          (currentMajor == storeMajor && currentMinor < storeMinor);
    } on Exception catch (_) {
      // エラーが発生した場合はアップデートを要求しない
      return false;
    }
  }
}
