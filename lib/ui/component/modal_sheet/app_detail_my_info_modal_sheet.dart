import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/utils/helpers/dialog_helper.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/helpers/url_launch_helper.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_share_widget.dart';
import 'package:food_gram_app/ui/component/dialog/app_share_dialog.dart';
import 'package:food_gram_app/ui/screen/detail/detail_post_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppDetailMyInfoModalSheet extends HookConsumerWidget {
  const AppDetailMyInfoModalSheet({
    required this.posts,
    required this.users,
    super.key,
  });

  final Posts posts;
  final Users users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final loading = useState(false);
    return Container(
      height: MediaQuery.sizeOf(context).width - 50,
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
            SizedBox(
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
                  await captureAndShare(
                    widget: AppShareWidget(posts: posts),
                    shareText: '${posts.foodName} '
                        'in ${posts.restaurant}',
                    loading: loading,
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.share,
                      color: Colors.black,
                      size: 25,
                    ),
                    Gap(20),
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
            Container(
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
                    await LaunchUrlHelper().open(URL.go(posts.restaurant));
                  } else {
                    SnackBarHelper()
                        .openError(context, l10n.postSearchError, '');
                  }
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.place,
                      color: Colors.black,
                      size: 25,
                    ),
                    Gap(20),
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
            Container(
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
                  DialogHelper().openDialog(
                    title: l10n.dialogDeleteTitle,
                    text: '${l10n.dialogDeleteDescription1}'
                        '\n '
                        '${l10n.dialogDeleteDescription2}',
                    onTap: () async {
                      context
                        ..pop()
                        ..pop()
                        ..pop(true);
                      await ref
                          .read(detailPostViewModelProvider().notifier)
                          .delete(posts);
                    },
                    context: context,
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 25,
                    ),
                    Gap(20),
                    Text(
                      l10n.dialogDeleteTitle,
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
            Container(
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
                    Gap(20),
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
          ],
        ),
      ),
    );
  }
}
