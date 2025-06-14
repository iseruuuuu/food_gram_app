import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/core/purchase/providers/subscription_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admob_open.g.dart';

/// アプリ起動時の広告を管理するクラス
class AdmobOpen {
  AdmobOpen({
    required this.isSubscribed,
  });

  AppOpenAd? _appOpenAd;
  bool _isAdShowing = false;
  final logger = Logger();
  final bool isSubscribed;

  /// 広告を読み込む
  void loadAd() {
    if (_appOpenAd != null) {
      return;
    }

    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: _onAdLoaded,
        onAdFailedToLoad: (error) =>
            logger.e('App open ad failed to load: $error'),
      ),
    );
  }

  /// 広告が利用可能な場合に表示する
  Future<void> showAdIfAvailable() async {
    if (_isAdShowing || _appOpenAd == null || isSubscribed) {
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

  void _onAdLoaded(AppOpenAd ad) {
    _appOpenAd = ad;
    _setupFullScreenCallback();
    showAdIfAvailable();
  }

  void _setupFullScreenCallback() {
    _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => logger.i('App open ad showed'),
      onAdDismissedFullScreenContent: (ad) {
        logger.i('App open ad dismissed');
        _onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        logger.e('App open ad failed to show: $error');
        _onAdClosed();
      },
    );
  }

  void _onAdClosed() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}

/// アプリ起動時の広告の状態を管理するプロバイダー
@riverpod
class AdmobOpenNotifier extends _$AdmobOpenNotifier {
  @override
  AdmobOpen build() {
    final isSubscribed =
        ref.watch(subscriptionProvider).whenOrNull(data: (value) => value) ??
            false;
    final admobOpen = AdmobOpen(isSubscribed: isSubscribed);
    ref.onDispose(admobOpen.dispose);
    return admobOpen;
  }
}
