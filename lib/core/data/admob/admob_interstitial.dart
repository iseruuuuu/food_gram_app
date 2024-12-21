import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:food_gram_app/core/data/purchase/subscription_provider.dart';
import 'package:food_gram_app/env.dart';
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
  // サブスク状態を管理

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
          print('add loaded');
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
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }

    // もし、サブスクに登録していたら、すぐにonAdClosedを呼び出す
    if (isSubscribed) {
      if (onAdClosed != null) {
        onAdClosed();
      }
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('Ad showed fullscreen');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('Ad dismissed');
        ad.dispose();
        createAd(); // 次の広告を準備
        if (onAdClosed != null) {
          onAdClosed(); // 広告が閉じた後の処理を実行
        }
      },
      onAdFailedToShowFullScreenContent: (ad, adError) {
        print('Ad failed to show: $adError');
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
