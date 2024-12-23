import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// BannerAd を管理する Provider
final bannerAdProvider = Provider<BannerAd>((ref) {
  final bannerId = getAdmobBannerId();
  return BannerAd(
    adUnitId: bannerId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  )..load();
});

class AdmobBanner extends ConsumerWidget {
  const AdmobBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAd = ref.watch(bannerAdProvider);
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }
}
