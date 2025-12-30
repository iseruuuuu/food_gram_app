import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

Future<void> showMaybeNotFoodDialog({
  required BuildContext context,
  required VoidCallback onContinue,
  required VoidCallback onDelete,
  String title = 'ちょっと確認 🍽️',
  String text = 'この写真、\n食べものじゃないかも…？と\nFoodGramが首をかしげています 🤔\n\nそれでも投稿しますか？',
}) async {
  await QuickAlert.show(
    context: context,
    type: QuickAlertType.warning,
    title: title,
    text: text,
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
