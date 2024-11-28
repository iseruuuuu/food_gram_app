import 'package:share_plus/share_plus.dart';

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
