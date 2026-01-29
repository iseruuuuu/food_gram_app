import 'package:flutter/material.dart';
import 'package:food_gram_app/i18n/strings.g.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

Future<void> showMaybeNotFoodDialog({
  required BuildContext context,
  required VoidCallback onContinue,
  required VoidCallback onDelete,
}) async {
  final t = Translations.of(context);
  final resolvedTitle = t.maybeNotFoodDialogTitle;
  final resolvedText = t.maybeNotFoodDialogText;
  final resolvedConfirmText = t.maybeNotFoodDialogConfirm;
  final resolvedDeleteText = t.maybeNotFoodDialogDelete;
  await QuickAlert.show(
    context: context,
    type: QuickAlertType.warning,
    title: resolvedTitle,
    text: resolvedText,
    confirmBtnText: resolvedConfirmText,
    confirmBtnColor: Colors.black,
    onConfirmBtnTap: () {
      Navigator.of(context).pop();
      onContinue();
    },
    showCancelBtn: true,
    cancelBtnText: resolvedDeleteText,
    onCancelBtnTap: () {
      Navigator.of(context).pop();
      onDelete();
    },
    confirmBtnTextStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    cancelBtnTextStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
}
