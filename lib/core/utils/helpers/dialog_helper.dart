import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/utils/helpers/url_launch_helper.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class DialogHelper {
  void forceUpdateDialog(BuildContext context) {
    final l10n = L10n.of(context);
    QuickAlert.show(
      disableBackBtn: true,
      context: context,
      type: QuickAlertType.info,
      title: l10n.forceUpdateTitle,
      text: l10n.forceUpdateText,
      confirmBtnText: l10n.forceUpdateButtonTitle,
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
    required Function() onTap,
    required BuildContext context,
  }) {
    final l10n = L10n.of(context);
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: title,
      text: text,
      confirmBtnText: l10n.dialogYesButton,
      onConfirmBtnTap: onTap,
      confirmBtnTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      showCancelBtn: true,
      cancelBtnText: l10n.dialogNoButton,
      onCancelBtnTap: () => context.pop(),
      cancelBtnTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void openLogoutDialog({
    required String title,
    required String text,
    required Function() onTap,
    required BuildContext context,
  }) {
    final l10n = L10n.of(context);
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: title,
      text: text,
      confirmBtnText: l10n.dialogLogoutButton,
      onConfirmBtnTap: onTap,
      confirmBtnColor: Colors.red,
      confirmBtnTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      showCancelBtn: true,
      cancelBtnText: l10n.cancel,
      onCancelBtnTap: () => context.pop(),
      cancelBtnTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
