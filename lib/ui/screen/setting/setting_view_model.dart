import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/supabase/auth/services/auth_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/screen/setting/setting_state.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setting_view_model.g.dart';

@riverpod
class SettingViewModel extends _$SettingViewModel {
  @override
  SettingState build({
    SettingState initState = const SettingState(),
  }) {
    getData();
    return initState;
  }

  Loading get loading => ref.read(loadingProvider.notifier);
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Future<void> getData() async {
    final packageInfo = await PackageInfo.fromPlatform();
    state = state.copyWith(
      version: packageInfo.version,
    );
  }

  Future<void> review() async {
    loading.state = true;
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.openStoreListing(
        appStoreId: '6474065183',
      );
    }
    loading.state = false;
  }

  Future<void> checkNewVersion(BuildContext context) async {
    loading.state = true;
    final l10n = L10n.of(context);
    final newVersion = NewVersionPlus();
    final status = await newVersion.getVersionStatus();
    final packageInfo = await PackageInfo.fromPlatform();
    final storeVersion =
        double.parse(status!.storeVersion.replaceAll('.', '')) / 100;
    final appVersion =
        double.parse(packageInfo.version.replaceAll('.', '')) / 100;
    loading.state = false;
    if (storeVersion > appVersion) {
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: l10n.settingCheckVersionDialogTitle,
        dialogText: '${l10n.settingCheckVersionDialogText1}\n'
            '${l10n.settingCheckVersionDialogText2}',
        launchModeVersion: LaunchModeVersion.external,
      );
    } else {
      SnackBarHelper().openSimpleSnackBar(
        context,
        'This App is new version👍',
      );
    }
  }

  Future<bool> restore() async {
    loading.state = true;
    try {
      return await ref
          .read(revenueCatServiceProvider.notifier)
          .restorePurchase();
    } finally {
      loading.state = false;
    }
  }

  Future<bool> signOut() async {
    loading.state = true;
    await Future<void>.delayed(const Duration(seconds: 2));
    final result = await ref.read(authServiceProvider).signOut();
    result.whenOrNull(
      success: (_) {
        ref.read(currentUserProvider.notifier).clear();
        return true;
      },
    );
    loading.state = false;
    return false;
  }
}
