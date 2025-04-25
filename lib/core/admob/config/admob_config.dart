import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:food_gram_app/env.dart';

const bool _isTest = kDebugMode;

// テスト用広告ID
const _testIds = _TestAdIds(
  android: _AndroidTestIds(
    banner: 'ca-app-pub-3940256099942544/6300978111',
    interstitial: 'ca-app-pub-3940256099942544/1033173712',
    appOpen: 'ca-app-pub-3940256099942544/9257395921',
  ),
  ios: _IOSTestIds(
    banner: 'ca-app-pub-3940256099942544/2934735716',
    interstitial: 'ca-app-pub-3940256099942544/4411468910',
    appOpen: 'ca-app-pub-3940256099942544/5575463023',
  ),
);

// バナー広告
String get bannerAdUnitId {
  if (_isTest) {
    return Platform.isAndroid ? _testIds.android.banner : _testIds.ios.banner;
  }
  return Platform.isAndroid ? Env.androidBanner : Env.iOSBanner;
}

// インタースティシャル広告
String get interstitialAdUnitId {
  if (_isTest) {
    return Platform.isAndroid
        ? _testIds.android.interstitial
        : _testIds.ios.interstitial;
  }
  return Platform.isAndroid ? Env.androidInterstitial : Env.iOSInterstitial;
}

// アプリオープン広告
String get appOpenAdUnitId {
  if (_isTest) {
    return Platform.isAndroid ? _testIds.android.appOpen : _testIds.ios.appOpen;
  }
  return Platform.isAndroid ? Env.androidOpen : Env.iOSOpen;
}

// 広告の表示間隔
const Duration minInterstitialDuration = Duration(minutes: 3);
const Duration minAppOpenDuration = Duration(minutes: 5);

// テスト用広告IDを管理するクラス
class _TestAdIds {
  const _TestAdIds({
    required this.android,
    required this.ios,
  });

  final _AndroidTestIds android;
  final _IOSTestIds ios;
}

class _AndroidTestIds {
  const _AndroidTestIds({
    required this.banner,
    required this.interstitial,
    required this.appOpen,
  });

  final String banner;
  final String interstitial;
  final String appOpen;
}

class _IOSTestIds {
  const _IOSTestIds({
    required this.banner,
    required this.interstitial,
    required this.appOpen,
  });

  final String banner;
  final String interstitial;
  final String appOpen;
}
