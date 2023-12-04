import 'package:flutter/cupertino.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/detail/detail_post_state.dart';
import 'package:food_gram_app/utils/mixin/dialog_mixin.dart';
import 'package:food_gram_app/utils/mixin/url_launcher_mixin.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_post_view_model.g.dart';

@riverpod
class DetailPostViewModel extends _$DetailPostViewModel
    with DialogMixin, UrlLauncherMixin {
  @override
  DetailPostState build({
    DetailPostState initState = const DetailPostState(),
  }) {
    return initState;
  }

  void delete(BuildContext context, int id) {
    openDeleteDialog(
      context: context,
      delete: () async {
        await supabase.from('posts').delete().eq('id', id);
        context.pop();
      },
    );
  }

  void report(BuildContext context) {
    openReportDialog(
      context: context,
      openUrl: () async {
        await launcherUrl(
          'https://docs.google.com/forms/d/1uDNHpaPTNPK7tBjbfNW87ykYH3JZO0D2l10oBtVxaQA/edit',
          context,
        );
      },
    );
  }
}
