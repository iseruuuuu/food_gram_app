import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              onPressed: () => context.pop(),
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
    showCupertinoDialog(
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
              onPressed: () => context.pop(),
            ),
            CupertinoDialogAction(
              child: Text(
                '削除する',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                delete();
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }

  void openLogOutDialog({
    required BuildContext context,
    required Function() logout,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('ログアウト'),
          content: Text('ログアウトしますか?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'キャンセル',
                style: TextStyle(color: Colors.blueAccent),
              ),
              isDestructiveAction: true,
              onPressed: () => context.pop(),
            ),
            CupertinoDialogAction(
              child: Text(
                'ログアウト',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                logout();
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }

  void openDeleteAccountDialog({
    required BuildContext context,
    required Function() deleteAccount,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('アカウントの削除'),
          content: Text('アカウントの削除をしますか？\n削除を行うと、データの復旧はできません'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'キャンセル',
                style: TextStyle(color: Colors.blueAccent),
              ),
              isDestructiveAction: true,
              onPressed: () => context.pop(),
            ),
            CupertinoDialogAction(
              child: Text(
                'アカウント削除',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                deleteAccount();
                context.pop();
              },
            ),
          ],
        );
      },
    );
  }
}