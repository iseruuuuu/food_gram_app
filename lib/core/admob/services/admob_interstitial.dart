import 'package:flutter/foundation.dart';
import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/core/purchase/providers/subscription_provider.dart';
import 'package:food_gram_app/main.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admob_interstitial.g.dart';

class AdmobInterstitial {
  AdmobInterstitial({
    required this.isSubscribed,
    this.onAdStateChanged,
  });

  static const int maxLoadAttempts = 2;

  final bool isSubscribed;

  final void Function({required bool isReady})? onAdStateChanged;

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  int _loadAttempts = 0;
  bool _isAdShowing = false;
  DateTime? _lastAdShowTime;

  bool get isAdReady => _isAdReady;

  void createAd() {
    if (_isAdReady || _loadAttempts >= maxLoadAttempts) {
      return;
    }

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          logger.d('Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _isAdReady = true;
          _loadAttempts = 0;
          onAdStateChanged?.call(isReady: true);
        },
        onAdFailedToLoad: (error) {
          logger.e('Interstitial ad failed to load: ${error.message}');
          _loadAttempts++;
          if (_loadAttempts < maxLoadAttempts) {
            createAd();
          }
        },
      ),
    );
  }

  Future<void> showAd({VoidCallback? onAdClosed}) async {
    if (_isAdShowing || _interstitialAd == null) {
      logger.e('Attempted to show ad before it was ready');
      onAdClosed?.call();
      return;
    }

    // 前回の広告表示からの経過時間をチェック
    if (_lastAdShowTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShowTime!);
      if (timeSinceLastAd < minInterstitialDuration) {
        logger.i('Skipping ad due to minimum duration not met');
        onAdClosed?.call();
        return;
      }
    }

    if (isSubscribed) {
      onAdClosed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        logger.i('Ad displayed');
      },
      onAdDismissedFullScreenContent: (ad) {
        logger.i('Ad dismissed');
        ad.dispose();
        _isAdReady = false;
        createAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        logger.e('Failed to show ad: $error');
        ad.dispose();
        _isAdReady = false;
        createAd();
      },
    );

    try {
      _isAdShowing = true;
      _lastAdShowTime = DateTime.now();
      await _interstitialAd!.show();
    } on Exception catch (e) {
      logger.e('Error showing interstitial ad: $e');
    } finally {
      _isAdShowing = false;
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
    _isAdShowing = false;
  }
}

@riverpod
class AdmobInterstitialNotifier extends _$AdmobInterstitialNotifier {
  AdmobInterstitial? _admobInterstitial;

  @override
  AdmobInterstitial build() {
    final isSubscribed =
        ref.watch(subscriptionProvider).whenOrNull(data: (value) => value) ??
            false;

    if (_admobInterstitial == null) {
      _admobInterstitial = AdmobInterstitial(isSubscribed: isSubscribed);
      _admobInterstitial!.createAd();
    }

    return _admobInterstitial!;
  }

  void dispose() {
    _admobInterstitial?.dispose();
  }
}
