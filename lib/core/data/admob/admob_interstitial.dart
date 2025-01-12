import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:food_gram_app/core/data/purchase/subscription_provider.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/main.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admob_interstitial.g.dart';

// プラットフォームに応じたInterstitial IDを取得
String getAdmobInterstitialId() {
  if (Platform.isAndroid) {
    return kDebugMode
        ? 'ca-app-pub-3940256099942544/1033173712' // Androidデモ用インタースティシャル広告ID
        : Env.androidInterstitial;
  } else if (Platform.isIOS) {
    return kDebugMode
        ? 'ca-app-pub-3940256099942544/1033173712' // iOSデモ用インタースティシャル広告ID
        : Env.iOSInterstitial;
  }
  throw UnsupportedError('Unsupported platform');
}

// AdmobInterstitialの管理クラス
class AdmobInterstitial {
  AdmobInterstitial({required this.isSubscribed});

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  int _loadAttempts = 0;
  final bool isSubscribed;

  bool get isAdReady => _isAdReady;

  void createAd() {
    if (_isAdReady || _loadAttempts >= 2) return;

    InterstitialAd.load(
      adUnitId: getAdmobInterstitialId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          logger.d('Ad loaded successfully');
          _interstitialAd = ad;
          _isAdReady = true;
          _loadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          logger.e('Failed to load ad: $error');
          _loadAttempts++;
          if (_loadAttempts <= 2) {
            createAd();
          }
        },
      ),
    );
  }

  Future<void> showAd({VoidCallback? onAdClosed}) async {
    if (!_isAdReady || _interstitialAd == null) {
      logger.e('Attempted to show ad before it was ready');
      return;
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
        createAd(); // 再ロード
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        logger.e('Failed to show ad: $error');
        ad.dispose();
        _isAdReady = false;
        createAd(); // 再ロード
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null;
    _isAdReady = false;
  }

  void dispose() {
    _interstitialAd?.dispose();
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

  @override
  void dispose() {
    _admobInterstitial?.dispose();
    // super.dispose();
  }
}
