import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    _checkSubscriptionAndLoadAd();
  }

  final Ref ref;
  final String id;

  void _checkSubscriptionAndLoadAd() {
    final subscriptionState = ref.read(isSubscribeProvider);
    subscriptionState.whenData((isSubscribed) {
      if (!isSubscribed) {
        _loadAd();
      }
    });
  }

  /// 広告を破棄する（サブスクリプション時に使用）
  void disposeAd() {
    state?.dispose();
    state = null;
  }

  void _loadAd() {
    if (state != null) {
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
          // 読み込み後にサブスクリプション状態を再確認
          final subscriptionState = ref.read(isSubscribeProvider);
          subscriptionState.whenData((isSubscribed) {
            if (isSubscribed) {
              ad.dispose();
              state = null;
            } else {
              state = ad as BannerAd;
            }
          });
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
    final subscriptionState = ref.watch(isSubscribeProvider);

    return subscriptionState.when(
      data: (isSubscribed) {
        // サブスクリプション状態が変更されたときに広告を破棄
        if (isSubscribed && bannerAd != null) {
          Future.microtask(() {
            ref.read(bannerAdProvider(id).notifier).disposeAd();
          });
        }
        return _buildBannerContainer(bannerAd, isSubscribed);
      },
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
    return const SizedBox(
      width: double.infinity,
      height: 0,
    );
  }
}

const adEvery = 30;
final adRowInterval = (adEvery / 3).floor();
