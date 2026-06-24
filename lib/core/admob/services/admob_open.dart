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
  int _loadAttempts = 0;
  DateTime? _lastAdShowTime;
  final Map<int, int> _tabOpenCounts = {};
  final logger = Logger();
  final bool isSubscribed;

  static const int maxLoadAttempts = 2;

  /// 広告を読み込む
  void loadAd() {
    if (isSubscribed) {
      return;
    }

    if (_appOpenAd != null || _loadAttempts >= maxLoadAttempts) {
      return;
    }

    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: _onAdLoaded,
        onAdFailedToLoad: _onAdFailedToLoad,
      ),
    );
  }

  /// タブを開いた回数を記録し、表示タイミングかどうかを返す
  bool registerTabOpenAndShouldShow(int tabIndex) {
    final count = (_tabOpenCounts[tabIndex] ?? 0) + 1;
    _tabOpenCounts[tabIndex] = count;
    return count % tabOpenAdInterval == 0;
  }

  /// 広告が利用可能な場合に表示する
  Future<void> showAdIfAvailable({VoidCallback? onAdClosed}) async {
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
      _isAdShowing = true;
      await _appOpenAd!.show();
      logger.d('App open ad show() called');
    } on Object catch (e) {
      logger.e('Error showing app open ad: $e');
      _disposeAd();
      loadAd();
      complete();
    } finally {
      _isAdShowing = false;
    }
  }

  bool _canShowAd() {
    if (_isAdShowing || _appOpenAd == null || isSubscribed) {
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
    _appOpenAd = ad;
    _loadAttempts = 0;
  }

  void _onAdFailedToLoad(LoadAdError error) {
    logger.e('App open ad failed to load: $error');
    _loadAttempts++;
    if (_loadAttempts < maxLoadAttempts) {
      loadAd();
    }
  }

  void _setupFullScreenCallback(VoidCallback onAdClosed) {
    _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _lastAdShowTime = DateTime.now();
        logger.i('App open ad showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        logger.i('App open ad dismissed');
        _disposeAd();
        loadAd();
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
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
    _tabOpenCounts.clear();
  }
}

/// アプリオープン広告の状態を管理するプロバイダー
@riverpod
class AdmobOpenNotifier extends _$AdmobOpenNotifier {
  AdmobOpen? _admobOpen;

  @override
  AdmobOpen build() {
    final subscriptionState = ref.watch(isSubscribeProvider);

    ref.onDispose(() => _admobOpen?.dispose());

    return subscriptionState.when(
      data: (isSubscribed) {
        if (_admobOpen == null) {
          _admobOpen = AdmobOpen(isSubscribed: isSubscribed);
          _admobOpen!.loadAd();
        } else {
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
