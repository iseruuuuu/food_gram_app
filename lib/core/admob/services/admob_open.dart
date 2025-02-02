import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/main.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admob_open.g.dart';

/// アプリ起動時の広告を管理するクラス
class AdmobOpen {
  AppOpenAd? _appOpenAd;
  bool _isAdShowing = false;

  void loadAd() {
    AppOpenAd.load(
      adUnitId: AdmobConfig.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: onAppOpenAdLoaded,
        onAdFailedToLoad: (error) {
          logger.e('App open ad failed to load: $error');
        },
      ),
    );
  }

  Future<void> showAdIfAvailable() async {
    if (_isAdShowing) {
      return;
    }

    try {
      _isAdShowing = true;
      await _appOpenAd?.show();
    } on Exception catch (e) {
      logger.e('Error showing app open ad: $e');
    } finally {
      _isAdShowing = false;
    }
  }

  void onAppOpenAdLoaded(AppOpenAd ad) {
    _appOpenAd = ad;

    _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        logger.i('App open ad showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        logger.i('App open ad dismissed');
        onAppOpenAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        logger.e('App open ad failed to show: $error');
        onAppOpenAdClosed();
      },
    );

    showAdIfAvailable();
  }

  void onAppOpenAdClosed() {
    _appOpenAd?.dispose();
  }

  void dispose() {
    _appOpenAd?.dispose();
  }
}

@riverpod
class AdmobOpenNotifier extends _$AdmobOpenNotifier {
  @override
  AdmobOpen build() {
    final admobOpen = AdmobOpen();
    ref.onDispose(admobOpen.dispose);
    return admobOpen;
  }
}
