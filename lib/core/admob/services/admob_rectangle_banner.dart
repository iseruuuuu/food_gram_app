import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/admob/admob_gate.dart';
import 'package:food_gram_app/core/admob/config/admob_config.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// レクタングル広告の状態を管理するプロバイダー
final rectangleBannerProvider =
    StateNotifierProvider.family<RectangleBannerNotifier, BannerAd?, String>(
  RectangleBannerNotifier.new,
);

/// レクタングル広告の状態を管理するNotifier
class RectangleBannerNotifier extends StateNotifier<BannerAd?> {
  RectangleBannerNotifier(this.ref, this.id) : super(null) {
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
      size: AdSize.mediumRectangle,
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

/// レクタングル広告を表示するウィジェット
class RectangleBanner extends ConsumerWidget {
  const RectangleBanner({
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

    final bannerAd = ref.watch(rectangleBannerProvider(id));
    if (bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Container(
        width: 300,
        height: 250,
        alignment: Alignment.center,
        child: AdWidget(ad: bannerAd),
      ),
    );
  }
}
