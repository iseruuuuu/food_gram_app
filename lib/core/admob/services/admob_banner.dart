import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/admob/admob_gate.dart';
import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// バナー広告の状態を管理するプロバイダー
final bannerAdProvider =
    StateNotifierProvider.family<BannerAdNotifier, BannerAd?, String>(
  BannerAdNotifier.new,
);

/// バナー広告の状態を管理するNotifier
class BannerAdNotifier extends StateNotifier<BannerAd?> {
  BannerAdNotifier(this.ref, this.id) : super(null) {
    ref.listen<AsyncValue<bool>>(isSubscribeProvider, (_, next) {
      if (!canRequestAds(next)) {
        disposeAd();
        return;
      }
      _loadAd();
    }, fireImmediately: true);
  }

  final Ref ref;
  final String id;

  /// 広告を破棄する（サブスクリプション時に使用）
  void disposeAd() {
    state?.dispose();
    state = null;
  }

  void _loadAd() {
    if (!canRequestAdsFrom(ref) || state != null) {
      return;
    }

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
          if (!canRequestAdsFrom(ref)) {
            ad.dispose();
            state = null;
            return;
          }
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
    final allowAds = canRequestAds(ref.watch(isSubscribeProvider));
    if (!allowAds) {
      return const SizedBox.shrink();
    }

    final bannerAd = ref.watch(bannerAdProvider(id));
    if (bannerAd == null) {
      return const SizedBox(width: double.infinity, height: 0);
    }

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }
}

const adEvery = 30;
final adRowInterval = (adEvery / 3).floor();
