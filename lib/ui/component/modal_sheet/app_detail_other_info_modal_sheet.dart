import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_share_widget.dart';
import 'package:food_gram_app/ui/component/dialog/app_dialog.dart';
import 'package:food_gram_app/ui/screen/detail/detail_post_view_model.dart';
import 'package:food_gram_app/utils/share.dart';
import 'package:food_gram_app/utils/snack_bar_manager.dart';
import 'package:food_gram_app/utils/url_launch.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class AppDetailOtherInfoModalSheet extends ConsumerWidget {
  const AppDetailOtherInfoModalSheet({
    required this.posts,
    required this.users,
    super.key,
  });

  final Posts posts;
  final Users users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    return Container(
      height: MediaQuery.sizeOf(context).width - 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              child: Text(
                l10n.postDetailSheetTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Color(0xFFEFEFEF),
                    foregroundColor: Color(0xFFEFEFEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    final screenshotController = ScreenshotController();
                    final screenshotBytes =
                        await screenshotController.captureFromWidget(
                      AppShareWidget(
                        posts: posts,
                        users: users,
                      ),
                    );

                    /// 一時ディレクトリに保存
                    final tempDir = await getTemporaryDirectory();
                    final filePath = '${tempDir.path}/shared_image.png';
                    final file = File(filePath);
                    await file.writeAsBytes(screenshotBytes);
                    await sharePosts(
                      [XFile(file.path)],
                      '${posts.foodName} in ${posts.restaurant} \n#FoodGram',
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.share,
                        color: Colors.black,
                        size: 25,
                      ),
                      SizedBox(width: 20),
                      Text(
                        l10n.postDetailSheetShareButton,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Color(0xFFEFEFEF),
                    foregroundColor: Color(0xFFEFEFEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  onPressed: () async {
                    context.pop();
                    if (posts.restaurant != '不明' && posts.restaurant != '自炊') {
                      await LaunchUrl().open(URL.search(posts.restaurant));
                    } else {
                      openErrorSnackBar(context, l10n.postSearchError, '');
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.place,
                        color: Colors.black,
                        size: 25,
                      ),
                      SizedBox(width: 20),
                      Text(
                        l10n.appShareGoButton,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Color(0xFFEFEFEF),
                    foregroundColor: Color(0xFFEFEFEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  onPressed: () {
                    context.pop();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AppDialog(
                          title: l10n.dialogReportTitle,
                          subTitle: '${l10n.dialogReportDescription1}'
                              '\n '
                              '${l10n.dialogReportDescription2}',
                          onTap: () async {
                            await LaunchUrl().open(URL.report).then((value) {
                              context.pop();
                            });
                          },
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.announcement_outlined,
                        color: Colors.red,
                        size: 25,
                      ),
                      SizedBox(width: 20),
                      Text(
                        l10n.postDetailSheetReportButton,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Color(0xFFEFEFEF),
                    foregroundColor: Color(0xFFEFEFEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  onPressed: () {
                    context.pop();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AppDialog(
                          title: l10n.dialogBlockTitle,
                          subTitle: '${l10n.dialogBlockDescription1}'
                              '\n'
                              '${l10n.dialogBlockDescription2}'
                              '\n'
                              '${l10n.dialogBlockDescription3}',
                          onTap: () async {
                            await ref
                                .read(detailPostViewModelProvider().notifier)
                                .block(posts.userId)
                                .then((value) async {
                              if (value) {
                                context.pop(true);
                              }
                            });
                          },
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility_off,
                        color: Colors.red,
                        size: 25,
                      ),
                      SizedBox(width: 20),
                      Text(
                        l10n.postDetailSheetBlockButton,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Color(0xFFEFEFEF),
                    foregroundColor: Color(0xFFEFEFEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                  onPressed: () {
                    context.pop();
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 25,
                      ),
                      SizedBox(width: 20),
                      Text(
                        l10n.close,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
