import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/core/purchase/providers/subscription_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admob_open.g.dart';

/// アプリ起動時の広告を管理するクラス
class AdmobOpen {
  AdmobOpen({
    required this.isSubscribed,
  });

  AppOpenAd? _appOpenAd;
  bool _isAdShowing = false;
  final logger = Logger();
  final bool isSubscribed;

  /// 広告を読み込む
  void loadAd() {
    if (isSubscribed) {
      return;
    }

    if (_appOpenAd != null) {
      return;
    }

    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: _onAdLoaded,
        onAdFailedToLoad: (error) =>
            logger.e('App open ad failed to load: $error'),
      ),
    );
  }

  /// 広告が利用可能な場合に表示する
  Future<void> showAdIfAvailable() async {
    if (_isAdShowing || _appOpenAd == null || isSubscribed) {
      return;
    }

    try {
      _isAdShowing = true;
      await _appOpenAd?.show();
    } on Exception catch (e) {
      logger.e('Error showing app open ad: $e');
    } finally {
      _isAdShowing = false;
    }
  }

  void _onAdLoaded(AppOpenAd ad) {
    _appOpenAd = ad;
    _setupFullScreenCallback();
    showAdIfAvailable();
  }

  void _setupFullScreenCallback() {
    _appOpenAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => logger.i('App open ad showed'),
      onAdDismissedFullScreenContent: (ad) {
        logger.i('App open ad dismissed');
        _onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        logger.e('App open ad failed to show: $error');
        _onAdClosed();
      },
    );
  }

  void _onAdClosed() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}

/// アプリ起動時の広告の状態を管理するプロバイダー
@riverpod
class AdmobOpenNotifier extends _$AdmobOpenNotifier {
  AdmobOpen? _admobOpen;

  @override
  AdmobOpen build() {
    final subscriptionState = ref.watch(subscriptionProvider);

    ref.onDispose(() => _admobOpen?.dispose());

    return subscriptionState.when(
      data: (isSubscribed) {
        if (_admobOpen == null) {
          _admobOpen = AdmobOpen(isSubscribed: isSubscribed);
        } else {
          // サブスクリプション状態が変更された場合、新しいインスタンスを作成
          _admobOpen?.dispose();
          _admobOpen = AdmobOpen(isSubscribed: isSubscribed);
        }
        return _admobOpen!;
      },
      loading: () {
        // ローディング中は広告を表示しない
        _admobOpen ??= AdmobOpen(isSubscribed: true);
        return _admobOpen!;
      },
      error: (_, __) {
        // エラー時は広告を表示しない
        _admobOpen ??= AdmobOpen(isSubscribed: true);
        return _admobOpen!;
      },
    );
  }
}
