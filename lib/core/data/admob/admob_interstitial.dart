import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:food_gram_app/core/data/purchase/subscription_provider.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/main.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admob_interstitial.g.dart';

String getAdmobInterstitialId() {
  if (Platform.isAndroid) {
    return kDebugMode
        ? 'ca-app-pub-3940256099942544/1033173712' // Androidデモ用バナー広告ID
        : Env.androidInterstitial;
  } else if (Platform.isIOS) {
    return kDebugMode
        ? 'ca-app-pub-3940256099942544/1033173712' // iOSデモ用バナー広告ID
        : Env.iOSInterstitial;
  }
  throw UnsupportedError('Unsupported platform');
}

class AdmobInterstitial {
  AdmobInterstitial({required this.isSubscribed});

  InterstitialAd? _interstitialAd;
  int numOfAttemptLoad = 0;
  bool? ready;
  final bool isSubscribed;

  void createAd() {
    InterstitialAd.load(
      adUnitId: getAdmobInterstitialId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          logger.d('add loaded');
          _interstitialAd = ad;
          numOfAttemptLoad = 0;
          ready = true;
        },
        onAdFailedToLoad: (error) {
          numOfAttemptLoad++;
          _interstitialAd = null;
          if (numOfAttemptLoad <= 2) {
            createAd();
          }
        },
      ),
    );
  }

  Future<void> showAd({VoidCallback? onAdClosed}) async {
    ready = false;
    if (_interstitialAd == null) {
      logger.e('Warning: attempt to show interstitial before loaded');
      return;
    }

    if (isSubscribed) {
      if (onAdClosed != null) {
        onAdClosed();
      }
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        logger.i('Ad showed fullscreen');
      },
      onAdDismissedFullScreenContent: (ad) {
        logger.i('Ad dismissed');
        ad.dispose();
        createAd();
        if (onAdClosed != null) {
          onAdClosed();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, adError) {
        logger.e('Ad failed to show: $adError');
        ad.dispose();
        createAd();
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null;
  }
}

@riverpod
AdmobInterstitial admobInterstitial(AdmobInterstitialRef ref) {
  final isSubscribed =
      ref.watch(subscriptionProvider).whenOrNull(data: (value) => value) ??
          false;
  final openInterstitial = AdmobInterstitial(isSubscribed: isSubscribed)
    ..createAd();
  return openInterstitial;
}
