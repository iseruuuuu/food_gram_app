import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:food_gram_app/env.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

String getAdmobInterstitialId() {
  if (Platform.isAndroid) {
    return kDebugMode
        ? 'ca-app-pub-3940256099942544/9257395921' // Androidデモ用バナー広告ID
        : Env.androidOpen;
  } else if (Platform.isIOS) {
    return kDebugMode
        ? 'ca-app-pub-3940256099942544/9257395921' // iOSデモ用バナー広告ID
        : Env.iOSOpen;
  }
  throw UnsupportedError('Unsupported platform');
}

class AdmobOpen {
  AppOpenAd? _appOpenAd;
  bool _isAdLoaded = false;
  final logger = Logger();

  void loadAd() {
    AppOpenAd.load(
      adUnitId: getAdmobInterstitialId(),
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdLoaded = true;
          _appOpenAd?.show();
        },
        onAdFailedToLoad: (error) {
          logger.e('App open ad failed to load: $error');
        },
      ),
    );
  }

  void showAdIfLoaded() {
    if (_isAdLoaded) {
      _appOpenAd?.show();
    } else {
      loadAd();
    }
  }

  void onAppOpenAdLoaded(AppOpenAd ad) {
    _appOpenAd = ad;
    _isAdLoaded = true;
    showAdIfLoaded();
  }

  void onAppOpenAdFailedToLoad(LoadAdError error) {
    logger.e('App open ad failed to load: $error');
  }

  void onAppOpenAdClosed() {
    _appOpenAd?.dispose();
    _isAdLoaded = false;
    loadAd();
  }

  void dispose() {
    _appOpenAd?.dispose();
  }

  // implement onAdFailedToLoad
  FullScreenAdLoadErrorCallback get onAdFailedToLoad =>
      throw UnimplementedError();

  // implement onAdLoaded
  GenericAdEventCallback<AppOpenAd> get onAdLoaded =>
      throw UnimplementedError();
}
