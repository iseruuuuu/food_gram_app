import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/utils/helpers/url_launch_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class DialogHelper {
  void forceUpdateDialog(BuildContext context) {
    final t = Translations.of(context);
    QuickAlert.show(
      disableBackBtn: true,
      context: context,
      type: QuickAlertType.info,
      title: t.forceUpdateTitle,
      text: t.forceUpdateText,
      confirmBtnText: t.forceUpdateButtonTitle,
      confirmBtnColor: Colors.black,
      onConfirmBtnTap: () {
        if (Platform.isIOS) {
          LaunchUrlHelper().openSNSUrl(URL.appleStore);
        } else {
          LaunchUrlHelper().openSNSUrl(URL.googleStore);
        }
      },
    );
  }

  void openDialog({
    required String title,
    required String text,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final t = Translations.of(context);
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: title,
      text: text,
      confirmBtnText: t.dialogYesButton,
      onConfirmBtnTap: onTap,
      confirmBtnTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      showCancelBtn: true,
      cancelBtnText: t.dialogNoButton,
      onCancelBtnTap: () => context.pop(),
      cancelBtnTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void openLogoutDialog({
    required String title,
    required String text,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final t = Translations.of(context);
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: title,
      text: text,
      confirmBtnText: t.dialogLogoutButton,
      onConfirmBtnTap: onTap,
      confirmBtnColor: Colors.red,
      confirmBtnTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      showCancelBtn: true,
      cancelBtnText: t.cancel,
      onCancelBtnTap: () => context.pop(),
      cancelBtnTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
