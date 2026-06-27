import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admob_open.g.dart';

/// アプリオープン広告を管理するクラス
class AdmobOpen {
  AdmobOpen({
    required this.isSubscribed,
  });

  AppOpenAd? _appOpenAd;
  bool _isAdShowing = false;
  bool _isAdLoading = false;
  int _loadAttempts = 0;
  DateTime? _lastAdShowTime;
  int _tabSwitchCount = 0;
  final logger = Logger();
  final bool isSubscribed;

  static const int maxLoadAttempts = 2;
  static const Duration adReadyTimeout = Duration(seconds: 5);

  bool get isAdReady => _appOpenAd != null;

  /// 広告を読み込む
  void loadAd({bool resetAttempts = false}) {
    if (isSubscribed) {
      return;
    }

    if (resetAttempts) {
      _loadAttempts = 0;
    }

    if (_appOpenAd != null || _isAdLoading || _loadAttempts >= maxLoadAttempts) {
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

  /// タブ切り替え回数を記録し、表示タイミングかどうかを返す
  bool registerTabSwitchAndShouldShow() {
    _tabSwitchCount++;
    final shouldShow = _tabSwitchCount % tabOpenAdInterval == 0;
    logger.d(
      'Tab switch count: $_tabSwitchCount / interval: $tabOpenAdInterval, '
      'shouldShow: $shouldShow',
    );
    return shouldShow;
  }

  /// 表示可能になるまで広告の読み込みを待つ
  Future<bool> ensureAdReady({
    Duration timeout = adReadyTimeout,
    bool resetAttempts = false,
  }) async {
    if (isSubscribed) {
      return false;
    }
    if (_appOpenAd != null) {
      return true;
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
    try {
      await _appOpenAd!.show();
      logger.d('App open ad show() called');
    } on Object catch (e) {
      _isAdShowing = false;
      logger.e('Error showing app open ad: $e');
      _disposeAd();
      loadAd();
      complete();
    }
  }

  bool _canShowAd() {
    if (isSubscribed) {
      logger.d('App open ad skipped: subscribed');
      return false;
    }
    if (_isAdShowing) {
      logger.d('App open ad skipped: already showing');
      return false;
    }
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
    logger.d('App open ad loaded successfully');
    _appOpenAd?.dispose();
    _appOpenAd = ad;
    _isAdLoading = false;
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
        logger.i('App open ad dismissed');
        _disposeAd();
        loadAd();
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isAdShowing = false;
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
  }

  void dispose() {
    _disposeAd();
    _isAdShowing = false;
    _isAdLoading = false;
    _tabSwitchCount = 0;
  }
}

/// アプリオープン広告の状態を管理するプロバイダー
@Riverpod(keepAlive: true)
class AdmobOpenNotifier extends _$AdmobOpenNotifier {
  AdmobOpen? _admobOpen;

  @override
  AdmobOpen build() {
    final subscriptionState = ref.watch(isSubscribeProvider);

    ref.onDispose(() => _admobOpen?.dispose());

    return subscriptionState.when(
      data: (isSubscribed) {
        if (_admobOpen == null || _admobOpen!.isSubscribed != isSubscribed) {
          _admobOpen?.dispose();
          _admobOpen = AdmobOpen(isSubscribed: isSubscribed);
          _admobOpen!.loadAd();
        }
        return _admobOpen!;
      },
      loading: () {
        _admobOpen ??= AdmobOpen(isSubscribed: true);
        return _admobOpen!;
      },
      error: (_, __) {
        _admobOpen ??= AdmobOpen(isSubscribed: true);
        return _admobOpen!;
      },
    );
  }
}
