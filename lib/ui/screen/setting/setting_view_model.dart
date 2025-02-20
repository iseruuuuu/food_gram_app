import 'dart:io';

import 'package:battery_info/battery_info_plugin.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/supabase/auth/services/auth_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
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
    if (Platform.isAndroid) {
      final battery = await BatteryInfoPlugin().androidBatteryInfo;
      final info = await deviceInfo.androidInfo;
      state = state.copyWith(
        sdk: info.version.sdkInt.toString(),
        model: info.model,
        battery: '${battery?.batteryLevel}%',
      );
    } else if (Platform.isIOS) {
      final battery = await BatteryInfoPlugin().iosBatteryInfo;
      final info = await deviceInfo.iosInfo;
      state = state.copyWith(
        sdk: info.systemVersion,
        model: info.model,
        battery: '${battery?.batteryLevel}%',
      );
    }
    state = state.copyWith(
      version: packageInfo.version,
    );
  }

  Future<void> review() async {
    loading.state = true;
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      loading.state = false;
      await inAppReview.requestReview();
    }
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
        dialogTitle: l10n.settingsCheckVersionDialogTitle,
        dialogText: '${l10n.settingsCheckVersionDialogText1}\n'
            '${l10n.settingsCheckVersionDialogText2}',
        launchModeVersion: LaunchModeVersion.external,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This App is new version👍'),
        ),
      );
    }
  }

  Future<bool> purchase() async {
    loading.state = true;
    try {
      return await ref
          .read(revenueCatServiceProvider.notifier)
          .makePurchase('FoodGramのメンバーシップ');
    } finally {
      loading.state = false;
    }
  }

  Future<bool> restore() async {
    loading.state = true;
    try {
      return await ref
          .read(revenueCatServiceProvider.notifier)
          .restorePurchase('foodgram_premium_membership');
    } finally {
      loading.state = false;
    }
  }

  Future<bool> signOut() async {
    loading.state = true;
    await Future.delayed(Duration(seconds: 2));
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
