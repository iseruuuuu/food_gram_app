import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

mixin UrlLauncherMixin {
  Future<void> launcherUrl(String uri, BuildContext context) async {
    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラー：ページが表示できませんでした'),
        ),
      );
    }
  }

  Future<void> openSNSUrl(
    String url,
    String secondUrl,
    BuildContext context,
  ) async {
    final snsUrl = Uri.parse(url);
    final snsSecondUrk = Uri.parse(secondUrl);
    if (await canLaunchUrl(snsUrl)) {
      await launchUrl(snsUrl);
    } else if (await canLaunchUrl(snsSecondUrk)) {
      await launchUrl(snsSecondUrk);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラー：ページが表示できませんでした'),
        ),
      );
    }
  }
}
