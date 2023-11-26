import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

mixin DialogMixin {
  void openReportDialog({
    required BuildContext context,
    required Function() openUrl,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('投稿の報告'),
          content: Text('Googleフォームに遷移します'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'キャンセル',
                style: TextStyle(color: Colors.blueAccent),
              ),
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: Text(
                '報告する',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: openUrl,
            ),
          ],
        );
      },
    );
  }

  void openDeleteDialog({
    required BuildContext context,
    required Function() delete,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('投稿の削除'),
          content: Text('この投稿を削除しますか？\n一度削除してしまうと復元できません'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'キャンセル',
                style: TextStyle(color: Colors.blueAccent),
              ),
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: Text(
                '削除する',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                delete();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
