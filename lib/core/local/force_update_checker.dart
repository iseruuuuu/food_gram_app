import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'force_update_checker.g.dart';

@riverpod
class ForceUpdateChecker extends _$ForceUpdateChecker {
  @override
  void build() {}

  /// ストアのバージョンと現在のバージョンを比較し、
  /// 強制アップデートが必要な場合はダイアログを表示する
  Future<void> checkForceUpdate({required void Function() openDialog}) async {
    final currentVersion = await _getCurrentVersion();
    final storeVersion = await _getStoreVersion();

    if (storeVersion == null) {
      /// ストア情報が取得できない場合、強制アップデートはしない
      return;
    }

    if (shouldForceUpdate(currentVersion, storeVersion)) {
      openDialog();
    }
  }

  /// 現在のアプリバージョンを取得
  Future<String> _getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// ストアの最新バージョンを取得
  Future<String?> _getStoreVersion() async {
    final newVersion = NewVersionPlus();
    final status = await newVersion.getVersionStatus();
    return status?.storeVersion;
  }

  /// メジャーまたはマイナーバージョンに変化があるかを確認
  bool shouldForceUpdate(String currentVersion, String storeVersion) {
    try {
      final currentParts = _parseVersion(currentVersion);
      final storeParts = _parseVersion(storeVersion);

      if (currentParts == null || storeParts == null) {
        return false;
      }

      final (currentMajor, currentMinor) = currentParts;
      final (storeMajor, storeMinor) = storeParts;

      return currentMajor < storeMajor ||
          (currentMajor == storeMajor && currentMinor < storeMinor);
    } on Exception catch (_) {
      return false;
    }
  }

  /// バージョン文字列をメジャーとマイナーバージョンに分解
  (int major, int minor)? _parseVersion(String version) {
    final parts = version.split('.');
    if (parts.length < 2) {
      return null;
    }

    try {
      return (
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    } on FormatException {
      return null;
    }
  }
}
