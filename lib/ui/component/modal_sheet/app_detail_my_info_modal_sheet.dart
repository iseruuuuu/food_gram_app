import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/utils/helpers/dialog_helper.dart';
import 'package:food_gram_app/core/utils/helpers/share_helper.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/helpers/url_launch_helper.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';

class AppDetailMyInfoModalSheet extends ConsumerWidget {
  const AppDetailMyInfoModalSheet({
    required this.posts,
    required this.users,
    required this.loading,
    required this.delete,
    required this.setUser,
    super.key,
  });

  final Posts posts;
  final Users users;
  final ValueNotifier<bool> loading;
  final Future<void> Function(Posts posts) delete;
  final void Function(Posts posts) setUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    return Container(
      height: MediaQuery.sizeOf(context).width,
      decoration: const BoxDecoration(
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
                style: const TextStyle(
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
                  backgroundColor: const Color(0xFFEFEFEF),
                  foregroundColor: const Color(0xFFEFEFEF),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                ),
                onPressed: () async {
                  context.pop();
                  await context
                      .pushNamed(
                    RouterPath.myProfileEditPost,
                    extra: posts,
                  )
                      .then((value) {
                    if (value != null) {
                      setUser(value as Posts);
                    }
                  });
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit,
                      color: Colors.black,
                      size: 25,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      l10n.editPostButton,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFEFEFEF),
                    foregroundColor: const Color(0xFFEFEFEF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  onPressed: () async {
                    await ShareHelpers().openShareModal(
                      posts: posts,
                      ref: ref,
                      loading: loading,
                      context: context,
                      shareText: '${posts.foodName} '
                          'in ${posts.restaurant}',
                    );
                    context.pop();
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.share,
                        color: Colors.black,
                        size: 25,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        l10n.postDetailSheetShareButton,
                        style: const TextStyle(
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
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFEFEFEF),
                    foregroundColor: const Color(0xFFEFEFEF),
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
                          .openErrorSnackBar(context, l10n.postSearchError, '');
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.place,
                        color: Colors.black,
                        size: 25,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        l10n.appShareGoButton,
                        style: const TextStyle(
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
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFEFEFEF),
                    foregroundColor: const Color(0xFFEFEFEF),
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
                        await delete(posts);
                      },
                      context: context,
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 25,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        l10n.dialogDeleteTitle,
                        style: const TextStyle(
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
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFEFEFEF),
                    foregroundColor: const Color(0xFFEFEFEF),
                    shape: const RoundedRectangleBorder(
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
                      const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 25,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        l10n.close,
                        style: const TextStyle(
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
