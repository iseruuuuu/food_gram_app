import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AdTrackingPermission {
  Future<void> requestTracking() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;

    if (status == TrackingStatus.notDetermined) {
      // iOSの仕様に基づき、少し遅延を入れる
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }
}
