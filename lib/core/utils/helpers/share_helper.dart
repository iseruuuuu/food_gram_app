import 'package:share_plus/share_plus.dart';

class ShareHelpers {
  void shareNormal(String url) {
    Share.share(url);
  }

  Future<void> sharePosts(
    List<XFile> files,
    String text,
  ) async {
    await Share.shareXFiles(
      files,
      text: text,
    );
  }

  Future<void> sharePostsForInstagram(List<XFile> files) async {
    await Share.shareXFiles(files);
  }
}
