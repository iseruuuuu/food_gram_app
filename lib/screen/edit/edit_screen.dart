import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/component/app_edit_text_field.dart';
import 'package:food_gram_app/screen/edit/edit_view_model.dart';

class EditScreen extends ConsumerWidget {
  const EditScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(editViewModelProvider().notifier);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: ref.read(editViewModelProvider().notifier).update,
            child: const Text(
              '更新',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFEADDFF),
              radius: 60,
            ),
            TextButton(
              onPressed: ref.read(editViewModelProvider().notifier).onTapImage,
              child: const Text(
                'プロフィール画像を変更',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            AppEditTextField(
              title: '名前',
              controller: controller.nameTextController,
            ),
            AppEditTextField(
              title: 'ID',
              controller: controller.idTextController,
            ),
            AppEditSelfIntroductionTextField(
              controller: controller.selfIntroduceTextController,
            ),
          ],
        ),
      ),
    );
  }
}
