import 'package:flutter/foundation.dart';
import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admob_interstitial.g.dart';

/// インタースティシャル広告の状態を管理するクラス
class AdmobInterstitial {
  AdmobInterstitial({
    required this.isSubscribed,
    this.onAdStateChanged,
  });

  final logger = Logger();
  static const int maxLoadAttempts = 2;

  final bool isSubscribed;
  final void Function({required bool isReady})? onAdStateChanged;

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  int _loadAttempts = 0;
  bool _isAdShowing = false;
  DateTime? _lastAdShowTime;

  bool get isAdReady => _isAdReady;

  /// 広告を作成して読み込む
  void createAd() {
    if (isSubscribed) {
      return;
    }
    if (_isAdReady || _loadAttempts >= maxLoadAttempts) {
      return;
    }

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: _onAdLoaded,
        onAdFailedToLoad: _onAdFailedToLoad,
      ),
    );
  }

  void _onAdLoaded(InterstitialAd ad) {
    logger.d('Interstitial ad loaded successfully');
    _interstitialAd = ad;
    _isAdReady = true;
    _loadAttempts = 0;
    onAdStateChanged?.call(isReady: true);
  }

  void _onAdFailedToLoad(LoadAdError error) {
    logger.e('Interstitial ad failed to load: ${error.message}');
    _loadAttempts++;
    if (_loadAttempts < maxLoadAttempts) {
      createAd();
    }
  }

  /// 広告を表示する
  Future<void> showAd({VoidCallback? onAdClosed}) async {
    if (!_canShowAd()) {
      onAdClosed?.call();
      return;
    }

    _setupFullScreenCallback(onAdClosed);
    await _showAd();
  }

  bool _canShowAd() {
    if (_isAdShowing || _interstitialAd == null) {
      logger.e('Attempted to show ad before it was ready');
      return false;
    }

    if (_lastAdShowTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShowTime!);
      if (timeSinceLastAd < minInterstitialDuration) {
        logger.i('Skipping ad due to minimum duration not met');
        return false;
      }
    }

    if (isSubscribed) {
      return false;
    }

    return true;
  }

  void _setupFullScreenCallback(VoidCallback? onAdClosed) {
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => logger.i('Ad displayed'),
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
  }

  Future<void> _showAd() async {
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

/// インタースティシャル広告の状態を管理するプロバイダー
@riverpod
class AdmobInterstitialNotifier extends _$AdmobInterstitialNotifier {
  AdmobInterstitial? _admobInterstitial;

  @override
  AdmobInterstitial build() {
    final subscriptionState = ref.watch(isSubscribeProvider);

    ref.onDispose(() => _admobInterstitial?.dispose());

    return subscriptionState.when(
      data: (isSubscribed) {
        if (_admobInterstitial == null) {
          _admobInterstitial = AdmobInterstitial(isSubscribed: isSubscribed);
          _admobInterstitial!.createAd();
        } else {
          // サブスクリプション状態が変更された場合、新しいインスタンスを作成
          _admobInterstitial?.dispose();
          _admobInterstitial = AdmobInterstitial(isSubscribed: isSubscribed);
          _admobInterstitial!.createAd();
        }
        return _admobInterstitial!;
      },
      loading: () {
        // ローディング中は広告を表示しない
        _admobInterstitial ??= AdmobInterstitial(isSubscribed: true);
        return _admobInterstitial!;
      },
      error: (_, __) {
        // エラー時は広告を表示しない
        _admobInterstitial ??= AdmobInterstitial(isSubscribed: true);
        return _admobInterstitial!;
      },
    );
  }
}
