import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

Future<void> showMaybeNotFoodDialog({
  required BuildContext context,
  required VoidCallback onContinue,
  required VoidCallback onDelete,
}) async {
  final l10n = L10n.of(context);
  final resolvedTitle = l10n.maybeNotFoodDialogTitle;
  final resolvedText = l10n.maybeNotFoodDialogText;
  await QuickAlert.show(
    context: context,
    type: QuickAlertType.warning,
    title: resolvedTitle,
    text: resolvedText,
    confirmBtnText: '続ける',
    confirmBtnColor: Colors.black,
    onConfirmBtnTap: () {
      Navigator.of(context).pop();
      onContinue();
    },
    showCancelBtn: true,
    cancelBtnText: '画像を削除',
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
