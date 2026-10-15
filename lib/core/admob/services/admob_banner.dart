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
    ref.listen<AsyncValue<bool>>(
      isSubscribeProvider,
      (_, next) {
        if (!canRequestAds(next)) {
          disposeAd();
          return;
        }
        final width = _width;
        if (width != null) {
          loadForWidth(width, force: true);
        }
      },
      fireImmediately: true,
    );
  }

  final Ref ref;
  final String id;
  int? _width;
  int _loadGeneration = 0;
  bool _isLoading = false;
  bool _disposed = false;

  /// 広告を破棄する（サブスクリプション時に使用）
  void disposeAd() {
    _loadGeneration++;
    _isLoading = false;
    state?.dispose();
    state = null;
  }

  /// 表示幅いっぱいに合わせたアンカーバナーを読み込む。高さは50前後。
  Future<void> loadForWidth(int width, {bool force = false}) async {
    if (_disposed || width <= 0 || !canRequestAdsFrom(ref)) {
      return;
    }
    if (!force && _width == width && (state != null || _isLoading)) {
      return;
    }
    _width = width;
    final generation = ++_loadGeneration;
    _isLoading = true;
    state?.dispose();
    state = null;

    final size = await _anchoredSize(width);
    if (_disposed || generation != _loadGeneration || !canRequestAdsFrom(ref)) {
      return;
    }

    BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (generation != _loadGeneration) {
            return;
          }
          _isLoading = false;
          state = null;
        },
        onAdLoaded: (ad) {
          if (_disposed ||
              generation != _loadGeneration ||
              !canRequestAdsFrom(ref)) {
            ad.dispose();
            return;
          }
          _isLoading = false;
          state = ad as BannerAd;
        },
      ),
    ).load();
  }

  Future<AdSize> _anchoredSize(int width) async {
    try {
      final adaptive = await AdSize
          .getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
      if (adaptive != null) {
        return adaptive;
      }
    } on Object {
      // 幅が取れない環境では従来の320×50に戻す。
    }
    return AdSize.banner;
  }

  @override
  void dispose() {
    _disposed = true;
    _loadGeneration++;
    state?.dispose();
    super.dispose();
  }
}

/// バナー広告を表示するウィジェット
class AdmobBanner extends ConsumerStatefulWidget {
  const AdmobBanner({
    required this.id,
    super.key,
  });

  final String id;

  @override
  ConsumerState<AdmobBanner> createState() => _AdmobBannerState();
}

class _AdmobBannerState extends ConsumerState<AdmobBanner> {
  int? _scheduledWidth;

  void _scheduleLoad(int width) {
    if (width <= 0 || _scheduledWidth == width) {
      return;
    }
    _scheduledWidth = width;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(bannerAdProvider(widget.id).notifier).loadForWidth(width);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowAds = canRequestAds(ref.watch(isSubscribeProvider));
    if (!allowAds) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final rawWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        _scheduleLoad(rawWidth.truncate());
        final bannerAd = ref.watch(bannerAdProvider(widget.id));
        if (bannerAd == null) {
          return const SizedBox(width: double.infinity, height: 0);
        }
        return Container(
          width: double.infinity,
          alignment: Alignment.center,
          height: bannerAd.size.height.toDouble(),
          child: AdWidget(ad: bannerAd),
        );
      },
    );
  }
}

const adEvery = 30;
final adRowInterval = (adEvery / 3).floor();
