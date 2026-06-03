import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';

class AdTrackingPermission {
  Future<void> requestTracking() async {
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;

    if (status == TrackingStatus.notDetermined) {
      // iOSの仕様に基づき、少し遅延を入れる
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
    await FirebaseAnalyticsService.shared.syncCollectionWithAppTracking();
  }
}
