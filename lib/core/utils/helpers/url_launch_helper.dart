import 'package:flutter/services.dart';
import 'package:food_gram_app/core/utils/instagram_username.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchUrlHelper {
  Future<bool> open(String uri) async {
    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> openSNSUrl(String url) async {
    final canLaunch = await canLaunchUrl(Uri.parse(url));
    if (!canLaunch) {
      return false;
    }

    return launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  /// アプリが入っていれば Instagram、なければブラウザでプロフィールを開く。
  Future<bool> openInstagramProfile(String username) async {
    final handle = username.trim();
    if (handle.isEmpty) {
      return false;
    }
    final appUri = instagramAppUri(handle);
    if (await canLaunchUrl(appUri)) {
      try {
        final launched = await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          return true;
        }
      } on PlatformException {
        // 起動判定のあとでアプリが開けないときはブラウザへ戻す。
      }
    }
    return open(instagramWebUri(handle).toString());
  }
}
