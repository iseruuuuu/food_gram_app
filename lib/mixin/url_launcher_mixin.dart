import 'package:url_launcher/url_launcher.dart';

mixin UrlLauncherMixin {
  void launcherUrl(String uri) async {
    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      //TODO エラーハンドリング
      print('Could not launch $url');
    }
  }
}
