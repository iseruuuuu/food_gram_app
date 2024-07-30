import 'package:flutter/material.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_modal_sheet.dart';
import 'package:food_gram_app/widgetbook/ui/fake_data/fake_data.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// app_detail_modal_sheet
@widgetbook.UseCase(
  name: 'AppDetailOtherInfoModalSheet',
  type: AppDetailOtherInfoModalSheet,
)
AppDetailOtherInfoModalSheet appDetailOtherInfoModalSheet(
  BuildContext context,
) {
  return AppDetailOtherInfoModalSheet(
    posts: fakePosts,
    users: fakeUsers,
  );
}

@widgetbook.UseCase(
  name: 'AppDetailMyInfoModalSheet',
  type: AppDetailMyInfoModalSheet,
)
AppDetailMyInfoModalSheet appDetailMyInfoModalSheet(BuildContext context) {
  return AppDetailMyInfoModalSheet(
    posts: fakePosts,
    users: fakeUsers,
  );
}

/// app_modal_sheet
@widgetbook.UseCase(
  name: 'RestaurantInfoModalSheet',
  type: RestaurantInfoModalSheet,
)
RestaurantInfoModalSheet restaurantInfoModalSheet(BuildContext context) {
  return RestaurantInfoModalSheet(post: [fakePosts]);
}

@widgetbook.UseCase(
  name: 'AppImageModalSheet',
  type: AppImageModalSheet,
)
AppImageModalSheet appImageModalSheet(BuildContext context) {
  return AppImageModalSheet(camera: () {}, album: () {});
}
