import 'package:url_launcher/url_launcher.dart';

class LaunchUrlHelper {
  Future<bool> open(String uri) async {
    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
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
}
