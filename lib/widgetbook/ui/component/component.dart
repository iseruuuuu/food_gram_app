import 'package:flutter/material.dart';
import 'package:food_gram_app/ui/component/app_app_bar.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';
import 'package:food_gram_app/ui/component/app_empty.dart';
import 'package:food_gram_app/ui/component/app_error_widget.dart';
import 'package:food_gram_app/ui/component/app_floating_button.dart';
import 'package:food_gram_app/ui/component/app_header.dart';
import 'package:food_gram_app/ui/component/app_icon.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_profile_button.dart';
import 'package:food_gram_app/ui/component/app_request.dart';
import 'package:food_gram_app/ui/component/app_text_button.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/widgetbook/ui/fake_data/fake_data.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Appbar
@widgetbook.UseCase(
  name: 'AppAppBar',
  type: AppAppBar,
)
AppAppBar appAppBar(BuildContext context) {
  return const AppAppBar();
}

/// ElevatedButton
@widgetbook.UseCase(
  name: 'AppElevatedButton',
  type: AppElevatedButton,
)
AppElevatedButton appElevatedButton(BuildContext context) {
  return AppElevatedButton(onPressed: () {}, title: 'test');
}

/// Empty
@widgetbook.UseCase(
  name: 'AppEmpty',
  type: AppEmpty,
)
AppEmpty appEmpty(BuildContext context) {
  return const AppEmpty();
}

/// ErrorWidget
@widgetbook.UseCase(
  name: 'AppErrorWidget',
  type: AppErrorWidget,
)
AppErrorWidget appErrorWidget(BuildContext context) {
  return AppErrorWidget(onTap: () {});
}

/// FloatingButton
@widgetbook.UseCase(
  name: 'AppFloatingButton',
  type: AppFloatingButton,
)
AppFloatingButton appFloatingButton(BuildContext context) {
  return AppFloatingButton(onTap: () {});
}

/// Header
@widgetbook.UseCase(
  name: 'AppHeader',
  type: AppHeader,
)
AppHeader appHeader(BuildContext context) {
  return AppHeader(
    users: fakeUsers,
    length: 5,
    heartAmount: 5,
  );
}

/// Icon
@widgetbook.UseCase(
  name: 'AppIcon',
  type: AppIcon,
)
AppIcon appIcon(BuildContext context) {
  return AppIcon(onTap: () {}, number: 0);
}

/// AppLoading
@widgetbook.UseCase(
  name: 'AppLoading',
  type: AppLoading,
)
AppLoading appLoading(BuildContext context) {
  return const AppLoading(loading: true, status: 'test');
}

/// MyProfileButton
@widgetbook.UseCase(
  name: 'AppMyProfileButton',
  type: AppMyProfileButton,
)
AppMyProfileButton appMyProfileButton(BuildContext context) {
  return AppMyProfileButton(
    onTapEdit: () {},
    onTapExchange: () {},
  );
}

/// Request
@widgetbook.UseCase(
  name: 'AppRequest',
  type: AppRequest,
)
AppRequest appRequest(BuildContext context) {
  return const AppRequest();
}

/// TextButton
@widgetbook.UseCase(
  name: 'AppTextButton',
  type: AppTextButton,
)
AppTextButton appTextButton(BuildContext context) {
  return AppTextButton(
    onPressed: () {},
    title: 'test',
    color: Colors.white,
  );
}

/// TextField
@widgetbook.UseCase(
  name: 'AppSearchTextField',
  type: AppSearchTextField,
)
AppSearchTextField appSearchTextField(BuildContext context) {
  return AppSearchTextField(onSubmitted: (value) {});
}

@widgetbook.UseCase(
  name: 'AppFoodTextField',
  type: AppFoodTextField,
)
AppFoodTextField appFoodTextField(BuildContext context) {
  final controller = TextEditingController();
  return AppFoodTextField(controller: controller);
}

@widgetbook.UseCase(
  name: 'AppCommentTextField',
  type: AppCommentTextField,
)
AppCommentTextField appCommentTextField(BuildContext context) {
  final controller = TextEditingController();
  return AppCommentTextField(controller: controller);
}

@widgetbook.UseCase(
  name: 'AppAuthTextField',
  type: AppAuthTextField,
)
AppAuthTextField appAuthTextField(BuildContext context) {
  final controller = TextEditingController();
  return AppAuthTextField(controller: controller);
}

@widgetbook.UseCase(
  name: 'AppNameTextField',
  type: AppNameTextField,
)
AppNameTextField appNameTextField(BuildContext context) {
  final controller = TextEditingController();
  return AppNameTextField(controller: controller);
}

@widgetbook.UseCase(
  name: 'AppSelfIntroductionTextField',
  type: AppSelfIntroductionTextField,
)
AppSelfIntroductionTextField appSelfIntroductionTextField(
  BuildContext context,
) {
  final controller = TextEditingController();
  return AppSelfIntroductionTextField(controller: controller);
}

@widgetbook.UseCase(
  name: 'AppUserNameTextField',
  type: AppUserNameTextField,
)
AppUserNameTextField appUserNameTextField(BuildContext context) {
  final controller = TextEditingController();
  return AppUserNameTextField(controller: controller);
}
