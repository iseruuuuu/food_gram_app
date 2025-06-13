import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/core/purchase/providers/subscription_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 広告の状態を管理するNotifier
class AdNotifier extends StateNotifier<BannerAd?> {
  AdNotifier({
    required this.ref,
    required this.adUnitId,
    required this.adSize,
  }) : super(null) {
    _loadAd();
  }

  final Ref ref;
  final String adUnitId;
  final AdSize adSize;

  void _loadAd() {
    if (state != null) {
      return;
    }

    BannerAd(
      adUnitId: adUnitId,
      size: adSize,
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

/// バナー広告の状態を管理するプロバイダー
final bannerAdProvider =
    StateNotifierProvider.family<AdNotifier, BannerAd?, String>((ref, id) {
  return AdNotifier(
    ref: ref,
    adUnitId: bannerAdUnitId,
    adSize: AdSize.banner,
  );
});

/// レクタングル広告の状態を管理するプロバイダー
final rectangleBannerProvider =
    StateNotifierProvider<AdNotifier, BannerAd?>((ref) {
  return AdNotifier(
    ref: ref,
    adUnitId: bannerAdUnitId,
    adSize: AdSize.mediumRectangle,
  );
});

/// 広告を表示するウィジェット
class AdmobBanner extends ConsumerWidget {
  const AdmobBanner({
    required this.id,
    this.isRectangle = false,
    super.key,
  });

  final String id;
  final bool isRectangle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAd = ref.watch(
      isRectangle ? rectangleBannerProvider : bannerAdProvider(id),
    );
    final subscriptionState = ref.watch(subscriptionProvider);

    return subscriptionState.when(
      data: (isSubscribed) => _buildBannerContainer(bannerAd, isSubscribed),
      error: (_, __) => const SizedBox.shrink(),
      loading: () => _buildLoadingContainer(bannerAd),
    );
  }

  Widget _buildBannerContainer(BannerAd? bannerAd, bool isSubscribed) {
    if (isSubscribed || bannerAd == null) {
      return SizedBox(
        width: isRectangle ? 300 : double.infinity,
        height: isRectangle ? 250 : 0,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isRectangle ? 8 : 0),
      child: Container(
        width: isRectangle ? 300 : double.infinity,
        height: isRectangle ? 250 : bannerAd.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: bannerAd),
      ),
    );
  }

  Widget _buildLoadingContainer(BannerAd? bannerAd) {
    return SizedBox(
      width: isRectangle ? 300 : double.infinity,
      height: isRectangle ? 250 : bannerAd?.size.height.toDouble() ?? 50.0,
    );
  }
}

/// レクタングル広告を表示するウィジェット（互換性のために残す）
class RectangleBanner extends ConsumerWidget {
  const RectangleBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AdmobBanner(
      id: 'rectangle',
      isRectangle: true,
    );
  }
}

const adEvery = 30;
final adRowInterval = (adEvery / 3).floor();
