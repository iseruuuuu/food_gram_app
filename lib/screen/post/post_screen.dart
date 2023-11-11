import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/component/app_post_text_field.dart';
import 'package:food_gram_app/screen/post/post_view_model.dart';

class PostScreen extends ConsumerWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final controller = ref.watch(postViewModelProvider().notifier);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: ref.read(postViewModelProvider().notifier).onTapImage,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEADDFF),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xFF6750A4)),
                ),
                width: deviceWidth - 20,
                height: deviceWidth / 2,
                child: const Icon(Icons.add, size: 50),
              ),
            ),
            AppPostTextField(
              controller: controller.foodTextController,
              hintText: 'Food Name',
              maxLines: 1,
            ),
            //TODO レストラン名（ボタンで検索させる）
            GestureDetector(
              onTap: ref.read(postViewModelProvider().notifier).post,
              child: Container(
                width: MediaQuery.of(context).size.width - 20,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xFF6750A4)),
                ),
              ),
            ),
            AppPostTextField(
              controller: controller.commentTextController,
              hintText: 'Comment',
              maxLines: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: 50,
              child: ElevatedButton(
                onPressed: ref.read(postViewModelProvider().notifier).post,
                child: const Text(
                  'POST',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
