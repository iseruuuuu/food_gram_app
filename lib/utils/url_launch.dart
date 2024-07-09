import 'package:url_launcher/url_launcher.dart';

class LaunchUrl {
  Future<bool> open(String uri) async {
    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> openSNSUrl(
    String url,
    String secondUrl,
  ) async {
    final snsUrl = Uri.parse(url);
    final snsSecondUrk = Uri.parse(secondUrl);
    if (await canLaunchUrl(snsUrl)) {
      await launchUrl(snsUrl);
      return true;
    } else if (await canLaunchUrl(snsSecondUrk)) {
      await launchUrl(snsSecondUrk);
      return true;
    } else {
      return false;
    }
  }
}
