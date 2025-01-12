import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/data/purchase/subscription_provider.dart';
import 'package:food_gram_app/env.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Banner ID を取得する関数
String getAdmobBannerId() {
  if (Platform.isAndroid) {
    return kDebugMode
        ? 'ca-app-pub-3940256099942544/6300978111' // Androidデモ用バナー広告ID
        : Env.androidBanner;
  } else if (Platform.isIOS) {
    return kDebugMode
        ? 'ca-app-pub-3940256099942544/2934735716' // iOSデモ用バナー広告ID
        : Env.iOSBanner;
  }
  throw UnsupportedError('Unsupported platform');
}

// BannerAd を管理する StateNotifierProvider
final bannerAdProvider =
    StateNotifierProvider<BannerAdNotifier, BannerAd?>((ref) {
  return BannerAdNotifier();
});

class BannerAdNotifier extends StateNotifier<BannerAd?> {
  BannerAdNotifier() : super(null) {
    _loadAd();
  }

  void _loadAd() {
    final bannerId = getAdmobBannerId();
    final bannerAd = BannerAd(
      adUnitId: bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
    state = bannerAd;
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

class AdmobBanner extends ConsumerWidget {
  const AdmobBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAd = ref.watch(bannerAdProvider);
    final subscriptionState = ref.watch(subscriptionProvider);
    return subscriptionState.when(
      data: (isSubscribed) {
        return !isSubscribed && bannerAd != null
            ? Container(
                width: double.infinity,
                alignment: Alignment.center,
                height: bannerAd.size.height.toDouble(),
                child: AdWidget(ad: bannerAd),
              )
            : const SizedBox.shrink();
      },
      error: (_, __) {
        return const SizedBox.shrink();
      },
      loading: () {
        return SizedBox(
          width: double.infinity,
          height: bannerAd?.size.height.toDouble() ?? 50.0,
        );
      },
    );
  }
}
