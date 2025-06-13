import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/core/purchase/providers/subscription_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// バナー広告の状態を管理するプロバイダー
final bannerAdProvider =
    StateNotifierProvider.family<BannerAdNotifier, BannerAd?, String>(
        (ref, id) {
  return BannerAdNotifier(ref, id);
});

/// バナー広告の状態を管理するNotifier
class BannerAdNotifier extends StateNotifier<BannerAd?> {
  BannerAdNotifier(this.ref, this.id) : super(null) {
    _loadAd();
  }

  final Ref ref;
  final String id;

  void _loadAd() {
    BannerAd(
      adUnitId: bannerAdUnitId,
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

/// レクタングル広告の状態を管理するプロバイダー
final rectangleBannerProvider =
    StateNotifierProvider<RectangleBannerNotifier, BannerAd?>((ref) {
  return RectangleBannerNotifier();
});

/// レクタングル広告の状態を管理するNotifier
class RectangleBannerNotifier extends StateNotifier<BannerAd?> {
  RectangleBannerNotifier() : super(null) {
    _loadAd();
  }

  void _loadAd() {
    if (state != null) {
      return;
    }

    BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.mediumRectangle,
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

/// レクタングル広告を表示するウィジェット
class RectangleBanner extends ConsumerWidget {
  const RectangleBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAd = ref.watch(rectangleBannerProvider);
    final subscriptionState = ref.watch(subscriptionProvider);

    return subscriptionState.when(
      data: (isSubscribed) => _buildBannerContainer(bannerAd, isSubscribed),
      error: (_, __) => const SizedBox.shrink(),
      loading: _buildLoadingContainer,
    );
  }

  Widget _buildBannerContainer(BannerAd? bannerAd, bool isSubscribed) {
    if (isSubscribed || bannerAd == null) {
      return const SizedBox(
        width: 300,
        height: 250,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        alignment: Alignment.center,
        width: 300,
        height: 250,
        child: AdWidget(ad: bannerAd),
      ),
    );
  }

  Widget _buildLoadingContainer() {
    return const SizedBox(
      width: 300,
      height: 250,
    );
  }
}

const adEvery = 30;
final adRowInterval = (adEvery / 3).floor();
