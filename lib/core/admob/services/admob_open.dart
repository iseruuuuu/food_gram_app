import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:food_gram_app/core/admob/admob_gate.dart';
import 'package:food_gram_app/core/admob/app_open_policy.dart';
import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admob_open.g.dart';

/// アプリオープン広告を管理するクラス
class AdmobOpen {
  AdmobOpen({
    required bool Function() isAdsBlocked,
  }) : _isAdsBlocked = isAdsBlocked;

  AppOpenAd? _appOpenAd;
  var _isAdShowing = false;
  var _isAdLoading = false;
  var _loadAttempts = 0;
  DateTime? _lastAdShowTime;
  DateTime? _appOpenLoadTime;
  DateTime? _backgroundedAt;
  var _ignoreBackground = false;
  final logger = Logger();
  final bool Function() _isAdsBlocked;

  static const maxLoadAttempts = 2;
  static const adReadyTimeout = Duration(seconds: 5);
  static const maxCacheDuration = Duration(hours: 4);

  bool get isAdReady => _appOpenAd != null;

  /// 広告を読み込む
  void loadAd({bool resetAttempts = false}) {
    if (_isAdsBlocked()) {
      _disposeAd();
      return;
    }

    if (resetAttempts) {
      _loadAttempts = 0;
    }

    if (_appOpenAd != null ||
        _isAdLoading ||
        _loadAttempts >= maxLoadAttempts) {
      return;
    }

    _isAdLoading = true;
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: _onAdLoaded,
        onAdFailedToLoad: _onAdFailedToLoad,
      ),
    );
  }

  /// バックグラウンドへ入った時刻を記録する。広告表示中は無視する。
  void noteEnteredBackground() {
    if (_isAdShowing || _ignoreBackground) {
      return;
    }
    _backgroundedAt ??= DateTime.now();
  }

  /// 前面に戻ったとき、条件を満たしていれば読み込み済みの広告を出す。
  ///
  /// 未読み込みなら待たずに次回復帰用へ読み込む。起動を止めない。
  void onAppResumed({required bool screenBlocksAd}) {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (_isAdShowing || _ignoreBackground) {
      return;
    }
    if (!shouldShowAppOpenOnResume(
      backgroundedAt: backgroundedAt,
      now: DateTime.now(),
      lastShownAt: _lastAdShowTime,
      screenBlocksAd: screenBlocksAd,
    )) {
      loadAd();
      return;
    }
    unawaited(showAdIfAvailable());
  }

  /// 表示可能になるまで広告の読み込みを待つ
  Future<bool> ensureAdReady({
    Duration timeout = adReadyTimeout,
    bool resetAttempts = false,
  }) async {
    if (_isAdsBlocked()) {
      return false;
    }
    if (_appOpenAd != null) {
      _discardExpiredAdIfNeeded();
      return _appOpenAd != null;
    }

    loadAd(resetAttempts: resetAttempts);
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (_appOpenAd != null) {
        return true;
      }
      if (!_isAdLoading && _loadAttempts >= maxLoadAttempts) {
        logger.i('App open ad load aborted after $maxLoadAttempts attempts');
        return false;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    logger.i('App open ad load timed out after ${timeout.inSeconds}s');
    return _appOpenAd != null;
  }

  /// 広告が利用可能な場合に表示する
  Future<void> showAdIfAvailable({VoidCallback? onAdClosed}) async {
    if (_isAdShowing) {
      logger.d('App open ad is already showing');
      return;
    }

    if (!_canShowAd()) {
      loadAd();
      onAdClosed?.call();
      return;
    }

    var didComplete = false;
    void complete() {
      if (didComplete) {
        return;
      }
      didComplete = true;
      onAdClosed?.call();
    }

    _setupFullScreenCallback(complete);
    _ignoreBackground = true;
    try {
      await _appOpenAd!.show();
      logger.d('App open ad show() called');
    } on Object catch (e) {
      _isAdShowing = false;
      _ignoreBackground = false;
      logger.e('Error showing app open ad: $e');
      _disposeAd();
      loadAd();
      complete();
    }
  }

  bool _canShowAd() {
    if (_isAdsBlocked()) {
      logger.d('App open ad skipped: subscribed or undetermined');
      return false;
    }
    if (_isAdShowing) {
      logger.d('App open ad skipped: already showing');
      return false;
    }

    _discardExpiredAdIfNeeded();

    if (_appOpenAd == null) {
      logger.i('App open ad skipped: not loaded');
      return false;
    }

    if (_lastAdShowTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShowTime!);
      if (timeSinceLastAd < minAppOpenDuration) {
        logger.i('Skipping app open ad due to minimum duration not met');
        return false;
      }
    }

    return true;
  }

  void _onAdLoaded(AppOpenAd ad) {
    _isAdLoading = false;
    if (_isAdsBlocked()) {
      logger.d('App open ad discarded: subscribed or undetermined');
      ad.dispose();
      return;
    }
    logger.d('App open ad loaded successfully');
    _appOpenAd?.dispose();
    _appOpenAd = ad;
    _appOpenLoadTime = DateTime.now();
    _loadAttempts = 0;
  }

  void _onAdFailedToLoad(LoadAdError error) {
    logger.e('App open ad failed to load: $error');
    _isAdLoading = false;
    _loadAttempts++;
    if (_loadAttempts < maxLoadAttempts) {
      loadAd();
    }
  }

  void _setupFullScreenCallback(VoidCallback onAdClosed) {
    _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isAdShowing = true;
        _lastAdShowTime = DateTime.now();
        logger.i('App open ad showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        _isAdShowing = false;
        _ignoreBackground = false;
        _backgroundedAt = null;
        logger.i('App open ad dismissed');
        _disposeAd();
        loadAd();
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isAdShowing = false;
        _ignoreBackground = false;
        _backgroundedAt = null;
        logger.e('App open ad failed to show: $error');
        _disposeAd();
        loadAd();
        onAdClosed();
      },
    );
  }

  void _disposeAd() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _appOpenLoadTime = null;
  }

  void _discardExpiredAdIfNeeded() {
    if (_appOpenAd == null) {
      return;
    }
    if (_appOpenLoadTime == null ||
        DateTime.now().difference(_appOpenLoadTime!) > maxCacheDuration) {
      logger.i('Discarding expired app open ad');
      _disposeAd();
      loadAd();
    }
  }

  void discardLoadedAd() {
    _disposeAd();
    _isAdLoading = false;
  }

  void dispose() {
    _disposeAd();
    _isAdShowing = false;
    _isAdLoading = false;
    _ignoreBackground = false;
    _backgroundedAt = null;
  }
}

/// アプリオープン広告の状態を管理するプロバイダー
@Riverpod(keepAlive: true)
class AdmobOpenNotifier extends _$AdmobOpenNotifier {
  @override
  AdmobOpen build() {
    final admobOpen = AdmobOpen(
      isAdsBlocked: () => !canRequestAdsFrom(ref),
    );
    // watch にすると購読状態が変わるたび build が再実行され、
    // 前回ビルド分の onDispose で読み込み済み広告が破棄されてしまう。
    ref.listen(
      isSubscribeProvider,
      (_, next) {
        if (canRequestAds(next)) {
          admobOpen.loadAd(resetAttempts: true);
        } else {
          admobOpen.discardLoadedAd();
        }
      },
      fireImmediately: true,
    );
    ref.onDispose(admobOpen.dispose);
    return admobOpen;
  }
}
