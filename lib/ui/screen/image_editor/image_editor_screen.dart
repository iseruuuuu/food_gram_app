import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// 画像編集画面（トリミング・回転・モザイクなど）
/// [imagePath] で画像ファイルパスを受け取り、完了時に編集後の [Uint8List] を pop する。
/// キャンセル時は null を pop する。
class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({
    required this.imagePath,
    super.key,
  });

  final String imagePath;

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  bool _hasPopped = false;

  void _popOnce([Uint8List? bytes]) {
    if (_hasPopped) {
      return;
    }
    _hasPopped = true;
    if (!context.mounted) {
      return;
    }
    if (bytes != null) {
      context.pop<Uint8List>(bytes);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('画像編集'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _popOnce,
          ),
        ),
        body: const Center(
          child: Text('画像編集はモバイルアプリでご利用ください。'),
        ),
      );
    }

    final file = File(widget.imagePath);
    if (!file.existsSync()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('画像編集'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _popOnce,
          ),
        ),
        body: const Center(child: Text('画像ファイルが見つかりません。')),
      );
    }

    return ProImageEditor.file(
      file,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (bytes) async {
          _popOnce(bytes);
        },
        onCloseEditor: (_) {
          // OK押下時は onImageEditingComplete が先に呼ばれ、続けて onCloseEditor も呼ばれるため、
          // 二重に pop しないよう _popOnce で1回だけ閉じる（投稿画面まで閉じる不具合を防止）
          _popOnce();
        },
      ),
    );
  }
}
