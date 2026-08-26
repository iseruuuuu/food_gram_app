import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:food_gram_app/core/admob/admob_gate.dart';
import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admob_interstitial.g.dart';

/// インタースティシャル広告の状態を管理するクラス
class AdmobInterstitial {
  AdmobInterstitial({
    required bool Function() isAdsBlocked,
    this.onAdStateChanged,
  }) : _isAdsBlocked = isAdsBlocked;

  final logger = Logger();
  static const int maxLoadAttempts = 2;
  static const Duration adReadyTimeout = Duration(seconds: 5);

  final bool Function() _isAdsBlocked;
  final void Function({required bool isReady})? onAdStateChanged;

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  bool _isAdLoading = false;
  bool _isDisposed = false;
  int _loadGeneration = 0;
  int _loadAttempts = 0;
  bool _isAdShowing = false;
  DateTime? _lastAdShowTime;
  int _postDetailCloseCount = 0;
  bool _hasPendingPostDetailAd = false;

  bool get isAdReady => _isAdReady;

  /// 投稿詳細を閉じた回数を記録し、いま広告を表示すべきかを返す。
  ///
  /// 表示タイミングに当たっても未準備・クールダウン中なら false を返し、
  /// 表示権は次に閉じたときへ持ち越す。閉じる操作をロード待ちで
  /// ブロックしないための仕組み。
  bool registerPostDetailCloseAndShouldShow() {
    _postDetailCloseCount++;
    if (_postDetailCloseCount % postDetailCloseAdInterval == 0) {
      _hasPendingPostDetailAd = true;
    }
    logger.d(
      'Post detail close count: $_postDetailCloseCount / '
      'interval: $postDetailCloseAdInterval, '
      'pending: $_hasPendingPostDetailAd',
    );
    if (!_hasPendingPostDetailAd) {
      return false;
    }
    if (!_canShowAd()) {
      logger.i('Post detail ad deferred to the next close');
      createAd();
      return false;
    }
    return true;
  }

  /// 広告を作成して読み込む
  void createAd({bool resetAttempts = false}) {
    final isBlocked = _isAdsBlocked();
    if (isBlocked || _isDisposed) {
      logger.d(
        'Interstitial load skipped: blocked=$isBlocked, '
        'disposed=$_isDisposed',
      );
      return;
    }
    if (resetAttempts) {
      _loadAttempts = 0;
    }
    if (_isAdReady || _isAdLoading || _loadAttempts >= maxLoadAttempts) {
      logger.d(
        'Interstitial load skipped: ready=$_isAdReady, '
        'loading=$_isAdLoading, attempts=$_loadAttempts',
      );
      return;
    }

    logger.d('Interstitial load requested');
    final loadGeneration = ++_loadGeneration;
    _isAdLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _onAdLoaded(ad, loadGeneration),
        onAdFailedToLoad: (error) => _onAdFailedToLoad(error, loadGeneration),
      ),
    );
  }

  void _onAdLoaded(InterstitialAd ad, int loadGeneration) {
    if (_isDisposed || loadGeneration != _loadGeneration) {
      ad.dispose();
      return;
    }
    logger.d('Interstitial ad loaded successfully');
    _interstitialAd?.dispose();
    _interstitialAd = ad;
    _isAdReady = true;
    _isAdLoading = false;
    _loadAttempts = 0;
    onAdStateChanged?.call(isReady: true);
  }

  void _onAdFailedToLoad(LoadAdError error, int loadGeneration) {
    if (_isDisposed || loadGeneration != _loadGeneration) {
      return;
    }
    logger.e('Interstitial ad failed to load: ${error.message}');
    _isAdLoading = false;
    _loadAttempts++;
    if (_loadAttempts < maxLoadAttempts) {
      createAd();
    }
  }

  /// 表示可能になるまで広告の読み込みを待つ
  Future<bool> ensureAdReady({
    Duration timeout = adReadyTimeout,
    bool resetAttempts = false,
  }) async {
    if (_isAdsBlocked()) {
      return false;
    }
    if (_isAdReady && _interstitialAd != null) {
      return true;
    }

    createAd(resetAttempts: resetAttempts);
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (_isAdReady && _interstitialAd != null) {
        return true;
      }
      if (!_isAdLoading && _loadAttempts >= maxLoadAttempts) {
        logger
            .i('Interstitial ad load aborted after $maxLoadAttempts attempts');
        return false;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    logger.i('Interstitial ad load timed out after ${timeout.inSeconds}s');
    return _isAdReady && _interstitialAd != null;
  }

  /// 広告を表示する
  Future<void> showAd({
    VoidCallback? onAdClosed,
    VoidCallback? onAdShown,
  }) async {
    if (_isAdShowing) {
      logger.d('Interstitial ad is already showing');
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

    _setupFullScreenCallback(
      onAdClosed: complete,
      onAdShown: onAdShown,
    );
    await _showAd(onShowFailed: complete);
  }

  bool _canShowAd() {
    if (_isAdsBlocked()) {
      return false;
    }
    if (_isAdShowing) {
      return false;
    }
    if (!_isAdReady || _interstitialAd == null) {
      logger.d('Interstitial ad is not ready yet');
      return false;
    }

    if (_lastAdShowTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShowTime!);
      if (timeSinceLastAd < minInterstitialDuration) {
        logger.i('Skipping ad due to minimum duration not met');
        return false;
      }
    }

    return true;
  }

  void _setupFullScreenCallback({
    required VoidCallback onAdClosed,
    VoidCallback? onAdShown,
  }) {
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isAdShowing = true;
        _lastAdShowTime = DateTime.now();
        _hasPendingPostDetailAd = false;
        logger.i('Ad displayed');
        onAdShown?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        logger.i('Ad dismissed');
        _isAdShowing = false;
        ad.dispose();
        _interstitialAd = null;
        _isAdReady = false;
        createAd();
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        logger.e('Failed to show ad: $error');
        _isAdShowing = false;
        ad.dispose();
        _interstitialAd = null;
        _isAdReady = false;
        createAd();
        onAdClosed();
      },
    );
  }

  Future<void> _showAd({required VoidCallback onShowFailed}) async {
    try {
      await _interstitialAd!.show();
      logger.d('Interstitial show() called');
    } on Object catch (e) {
      _isAdShowing = false;
      logger.e('Error showing interstitial ad: $e');
      await _interstitialAd?.dispose();
      _interstitialAd = null;
      _isAdReady = false;
      createAd();
      onShowFailed();
    }
  }

  void discardLoadedAd() {
    _loadGeneration++;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
    _isAdLoading = false;
  }

  void dispose() {
    _loadGeneration++;
    _isDisposed = true;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
    _isAdLoading = false;
    _isAdShowing = false;
    _hasPendingPostDetailAd = false;
  }
}

/// インタースティシャル広告の状態を管理するプロバイダー
@Riverpod(keepAlive: true)
class AdmobInterstitialNotifier extends _$AdmobInterstitialNotifier {
  @override
  AdmobInterstitial build() {
    final interstitial = AdmobInterstitial(
      isAdsBlocked: () => !canRequestAdsFrom(ref),
    );
    // watch にすると購読状態が変わるたび build が再実行され、
    // 前回ビルド分の onDispose が走って広告インスタンスが無効化される。
    // listen なら build は一度だけで、onDispose も本当の破棄時にしか走らない。
    ref.listen(
      isSubscribeProvider,
      (_, next) {
        if (canRequestAds(next)) {
          interstitial.createAd(resetAttempts: true);
        } else {
          interstitial.discardLoadedAd();
        }
      },
      fireImmediately: true,
    );
    ref.onDispose(interstitial.dispose);
    return interstitial;
  }
}
