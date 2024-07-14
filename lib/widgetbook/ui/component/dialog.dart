import 'package:flutter/material.dart';
import 'package:food_gram_app/ui/component/dialog/app_dialog.dart';
import 'package:food_gram_app/ui/component/dialog/app_logout_dialog.dart';
import 'package:food_gram_app/ui/component/dialog/app_profile_dialog.dart';
import 'package:food_gram_app/ui/component/dialog/app_share_dialog.dart';
import 'package:food_gram_app/widgetbook/ui/fake_data/fake_data.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'AppDialog',
  type: AppDialog,
)
AppDialog appDialog(BuildContext context) {
  return AppDialog(
    onTap: () {},
    title: 'test title',
    subTitle: 'test subtitle',
  );
}

@widgetbook.UseCase(
  name: 'AppLogoutDialog',
  type: AppLogoutDialog,
)
AppLogoutDialog appLogoutDialog(BuildContext context) {
  return AppLogoutDialog(logout: () {});
}

@widgetbook.UseCase(
  name: 'AppProfileDialog',
  type: AppProfileDialog,
)
AppProfileDialog appProfileDialog(BuildContext context) {
  return AppProfileDialog(image: 'assets/icon/icon3.png');
}

@widgetbook.UseCase(
  name: 'AppShareDialog',
  type: AppShareDialog,
)
AppShareDialog appShareDialog(BuildContext context) {
  return AppShareDialog(
    posts: fakePosts,
    users: fakeUsers,
  );
}
