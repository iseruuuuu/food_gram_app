/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsGifGen {
  const $AssetsGifGen();

  /// File path: assets/gif/error.gif
  AssetGenImage get error => const AssetGenImage('assets/gif/error.gif');

  /// File path: assets/gif/login_1.gif
  AssetGenImage get login1 => const AssetGenImage('assets/gif/login_1.gif');

  /// File path: assets/gif/login_2.gif
  AssetGenImage get login2 => const AssetGenImage('assets/gif/login_2.gif');

  /// File path: assets/gif/login_3.gif
  AssetGenImage get login3 => const AssetGenImage('assets/gif/login_3.gif');

  /// File path: assets/gif/login_4.gif
  AssetGenImage get login4 => const AssetGenImage('assets/gif/login_4.gif');

  /// File path: assets/gif/my_profile.gif
  AssetGenImage get myProfile =>
      const AssetGenImage('assets/gif/my_profile.gif');

  /// File path: assets/gif/profile_detail.gif
  AssetGenImage get profileDetail =>
      const AssetGenImage('assets/gif/profile_detail.gif');

  /// List of all assets
  List<AssetGenImage> get values =>
      [error, login1, login2, login3, login4, myProfile, profileDetail];
}

class $AssetsIconGen {
  const $AssetsIconGen();

  /// File path: assets/icon/icon0.png
  AssetGenImage get icon0 => const AssetGenImage('assets/icon/icon0.png');

  /// File path: assets/icon/icon1.png
  AssetGenImage get icon1 => const AssetGenImage('assets/icon/icon1.png');

  /// File path: assets/icon/icon2.png
  AssetGenImage get icon2 => const AssetGenImage('assets/icon/icon2.png');

  /// File path: assets/icon/icon3.png
  AssetGenImage get icon3 => const AssetGenImage('assets/icon/icon3.png');

  /// File path: assets/icon/icon4.png
  AssetGenImage get icon4 => const AssetGenImage('assets/icon/icon4.png');

  /// File path: assets/icon/icon5.png
  AssetGenImage get icon5 => const AssetGenImage('assets/icon/icon5.png');

  /// File path: assets/icon/icon6.png
  AssetGenImage get icon6 => const AssetGenImage('assets/icon/icon6.png');

  /// List of all assets
  List<AssetGenImage> get values =>
      [icon0, icon1, icon2, icon3, icon4, icon5, icon6];
}

class $AssetsImageGen {
  const $AssetsImageGen();

  /// File path: assets/image/empty.png
  AssetGenImage get empty => const AssetGenImage('assets/image/empty.png');

  /// File path: assets/image/error.png
  AssetGenImage get error => const AssetGenImage('assets/image/error.png');

  /// File path: assets/image/food.png
  AssetGenImage get food => const AssetGenImage('assets/image/food.png');

  /// File path: assets/image/heart.gif
  AssetGenImage get heart => const AssetGenImage('assets/image/heart.gif');

  /// File path: assets/image/loading.gif
  AssetGenImage get loading => const AssetGenImage('assets/image/loading.gif');

  /// File path: assets/image/logo_google.png
  AssetGenImage get logoGoogle =>
      const AssetGenImage('assets/image/logo_google.png');

  /// File path: assets/image/pin.png
  AssetGenImage get pin => const AssetGenImage('assets/image/pin.png');

  /// File path: assets/image/tutorial1.png
  AssetGenImage get tutorial1 =>
      const AssetGenImage('assets/image/tutorial1.png');

  /// File path: assets/image/tutorial2.png
  AssetGenImage get tutorial2 =>
      const AssetGenImage('assets/image/tutorial2.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        empty,
        error,
        food,
        heart,
        loading,
        logoGoogle,
        pin,
        tutorial1,
        tutorial2
      ];
}

class $AssetsSplashGen {
  const $AssetsSplashGen();

  /// File path: assets/splash/splash.gif
  AssetGenImage get splashGif =>
      const AssetGenImage('assets/splash/splash.gif');

  /// File path: assets/splash/splash.png
  AssetGenImage get splashPng =>
      const AssetGenImage('assets/splash/splash.png');

  /// List of all assets
  List<AssetGenImage> get values => [splashGif, splashPng];
}

class Assets {
  Assets._();

  static const $AssetsGifGen gif = $AssetsGifGen();
  static const $AssetsIconGen icon = $AssetsIconGen();
  static const $AssetsImageGen image = $AssetsImageGen();
  static const $AssetsSplashGen splash = $AssetsSplashGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName, {this.size = null});

  final String _assetName;

  final Size? size;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
