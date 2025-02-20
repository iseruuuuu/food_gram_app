import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/core/purchase/providers/subscription_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 広告のプリロードを管理するプロバイダー
final preloadBannerAdsProvider = Provider((ref) => PreloadBannerAds());

/// 広告のプリロード管理クラス
class PreloadBannerAds {
  final Map<String, BannerAd> _preloadedAds = {};

  Future<void> preloadAds(List<String> adIds) async {
    for (final id in adIds) {
      if (!_preloadedAds.containsKey(id)) {
        final ad = BannerAd(
          adUnitId: AdmobConfig.bannerAdUnitId,
          size: AdSize.banner,
          request: const AdRequest(),
          listener: BannerAdListener(
            onAdFailedToLoad: (ad, error) {
              ad.dispose();
              _preloadedAds.remove(id);
            },
            onAdLoaded: (ad) {
              _preloadedAds[id] = ad as BannerAd;
            },
          ),
        );
        await ad.load();
      }
    }
  }

  BannerAd? getAd(String id) => _preloadedAds[id];

  void dispose() {
    for (final ad in _preloadedAds.values) {
      ad.dispose();
    }
    _preloadedAds.clear();
  }
}

/// バナー広告の状態を管理するプロバイダー
final bannerAdProvider =
    StateNotifierProvider.family<BannerAdNotifier, BannerAd?, String>(
        (ref, id) {
  return BannerAdNotifier(ref, id);
});

/// バナー広告の状態を管理するNotifier
class BannerAdNotifier extends StateNotifier<BannerAd?> {
  BannerAdNotifier(this.ref, this.id) : super(null) {
    final preloadedAd = ref.read(preloadBannerAdsProvider).getAd(id);
    if (preloadedAd != null) {
      state = preloadedAd;
    } else {
      _loadAd();
    }
  }

  final Ref ref;
  final String id;

  void _loadAd() {
    BannerAd(
      adUnitId: AdmobConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          state = null;
        },
        onAdLoaded: (ad) {
          state = ad as BannerAd;
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

/// バナー広告を表示するウィジェット
class AdmobBanner extends ConsumerWidget {
  const AdmobBanner({
    required this.id,
    super.key,
  });

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAd = ref.watch(bannerAdProvider(id));
    final subscriptionState = ref.watch(subscriptionProvider);

    return subscriptionState.when(
      data: (isSubscribed) => _buildBannerContainer(bannerAd, isSubscribed),
      error: (_, __) => const SizedBox.shrink(),
      loading: () => _buildLoadingContainer(bannerAd),
    );
  }

  Widget _buildBannerContainer(BannerAd? bannerAd, bool isSubscribed) {
    if (isSubscribed || bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

  Widget _buildLoadingContainer(BannerAd? bannerAd) {
    return SizedBox(
      width: double.infinity,
      height: bannerAd?.size.height.toDouble() ?? 50.0,
    );
  }
}

/// 現在表示中の広告位置を管理するプロバイダー
final currentAdPositionProvider = StateProvider<int>((ref) => 0);

/// 単一のレクタングル広告を管理するプロバイダー
final singleRectangleBannerProvider =
    StateNotifierProvider<SingleRectangleBannerNotifier, BannerAd?>((ref) {
  return SingleRectangleBannerNotifier();
});

/// 単一のレクタングル広告を管理するNotifier
class SingleRectangleBannerNotifier extends StateNotifier<BannerAd?> {
  SingleRectangleBannerNotifier() : super(null) {
    _loadAd();
  }

  void _loadAd() {
    if (state != null) {
      return; // 既に広告がロードされている場合は何もしない
    }

    BannerAd(
      adUnitId: AdmobConfig.bannerAdUnitId,
      size: AdSize.mediumRectangle, // レクタングル広告サイズ
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          state = null;
        },
        onAdLoaded: (ad) {
          state = ad as BannerAd;
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

/// 再利用可能なレクタングル広告ウィジェット
class ReusableRectangleBanner extends ConsumerWidget {
  const ReusableRectangleBanner({
    required this.position,
    super.key,
  });

  final int position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAd = ref.watch(singleRectangleBannerProvider);
    final subscriptionState = ref.watch(subscriptionProvider);
    final currentPosition = ref.watch(currentAdPositionProvider);

    // 現在の表示位置と一致する場合のみ広告を表示
    final isVisible = position == currentPosition;

    return subscriptionState.when(
      data: (isSubscribed) =>
          _buildBannerContainer(bannerAd, isSubscribed, isVisible),
      error: (_, __) => const SizedBox.shrink(),
      loading: _buildLoadingContainer,
    );
  }

  Widget _buildBannerContainer(
    BannerAd? bannerAd,
    bool isSubscribed,
    bool isVisible,
  ) {
    if (isSubscribed || bannerAd == null || !isVisible) {
      return const SizedBox(
        width: 300,
        height: 250,
      );
    }

    return Container(
      alignment: Alignment.center,
      width: 300,
      height: 250,
      child: AdWidget(ad: bannerAd),
    );
  }

  Widget _buildLoadingContainer() {
    return const SizedBox(
      width: 300,
      height: 250,
    );
  }
}
