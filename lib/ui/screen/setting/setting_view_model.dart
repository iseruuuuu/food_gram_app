import 'dart:io';

import 'package:battery_info/battery_info_plugin.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:food_gram_app/config/supabase/auth_service.dart';
import 'package:food_gram_app/ui/screen/setting/setting_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
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

  Future<bool> signOut() async {
    loading.state = true;
    await Future.delayed(Duration(seconds: 2));
    final result = await ref.read(authServiceProvider).signOut();
    result.whenOrNull(
      success: (_) {
        return true;
      },
    );
    loading.state = false;
    return false;
  }
}
