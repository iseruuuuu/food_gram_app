import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/component/dialog/app_dialog.dart';
import 'package:food_gram_app/ui/screen/detail/detail_post_view_model.dart';
import 'package:food_gram_app/utils/mixin/show_modal_bottom_sheet_mixin.dart';
import 'package:food_gram_app/utils/snack_bar_manager.dart';
import 'package:food_gram_app/utils/url_launch.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class DetailPostBottomSheet extends ConsumerWidget
    with ShowModalBottomSheetMixin {
  const DetailPostBottomSheet({
    required this.posts,
    required this.users,
    super.key,
  });

  final Posts posts;
  final Users users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = supabase.auth.currentUser?.id;
    return IconButton(
      onPressed: () {
        if (users.userId != user) {
          onTapOtherDetail(
            context: context,
            share: () {
              Share.share(
                '${users.name} post in '
                '${posts.restaurant}'
                '\n\n${L10n.of(context).share_review_1}'
                '\n${L10n.of(context).share_review_2}'
                '\n\n#foodGram'
                '\n#FoodGram',
              );
            },
            search: () async {
              if (posts.restaurant != '不明' && posts.restaurant != '自炊') {
                await LaunchUrl().open(
                  'https://www.google.com/maps/search/?api=1&query=${posts.restaurant}',
                );
              } else {
                openErrorSnackBar(
                  context,
                  L10n.of(context).posts_search_error,
                );
              }
            },
            report: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AppDialog(
                    title: L10n.of(context).dialog_report_title,
                    subTitle: '${L10n.of(context).dialog_report_description_1}'
                        '\n '
                        '${L10n.of(context).dialog_report_description_2}',
                    onTap: () async {
                      await LaunchUrl()
                          .open(
                        'https://docs.google.com/forms/d/1uDNHpaPTNPK7tBjbfNW87ykYH3JZO0D2l10oBtVxaQA/edit',
                      )
                          .then((value) {
                        context.pop();
                      });
                    },
                  );
                },
              );
            },
            block: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AppDialog(
                    title: L10n.of(context).dialog_block_title,
                    subTitle: '${L10n.of(context).dialog_block_description_1}'
                        '\n'
                        '${L10n.of(context).dialog_block_description_2}'
                        '\n'
                        '${L10n.of(context).dialog_block_description_3}',
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
          );
        } else {
          onTapMyDetail(
            context: context,
            share: () {
              Share.share(
                '${users.name} post in '
                '${posts.restaurant}'
                '\n\n${L10n.of(context).share_review_1}'
                '\n${L10n.of(context).share_review_2}'
                '\n\n#foodGram'
                '\n#FoodGram',
              );
            },
            search: () async {
              if (posts.restaurant != '不明' && posts.restaurant != '自炊') {
                await LaunchUrl().open(
                  'https://www.google.com/maps/search/?api=1&query=${posts.restaurant}',
                );
              } else {
                openErrorSnackBar(
                  context,
                  L10n.of(context).posts_search_error,
                );
              }
            },
            delete: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AppDialog(
                    title: L10n.of(context).dialog_delete_title,
                    subTitle: '${L10n.of(context).dialog_delete_description_1}'
                        '\n'
                        '${L10n.of(context).dialog_delete_description_2}',
                    onTap: () async {
                      await ref
                          .read(detailPostViewModelProvider().notifier)
                          .delete(posts)
                          .then((value) async {
                        if (value) {
                          context.pop(true);
                        } else {
                          openErrorSnackBar(
                            context,
                            L10n.of(context).dialog_delete_error,
                          );
                        }
                      });
                    },
                  );
                },
              );
            },
          );
        }
      },
      icon: Icon(Icons.menu),
    );
  }
}
