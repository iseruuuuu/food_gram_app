import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/component/app_loading.dart';
import 'package:food_gram_app/component/app_post_text_field.dart';
import 'package:food_gram_app/provider/loading.dart';
import 'package:food_gram_app/screen/post/post_view_model.dart';

class PostScreen extends ConsumerWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final controller = ref.watch(postViewModelProvider().notifier);
    final state = ref.watch(postViewModelProvider());
    final loading = ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: CupertinoColors.extraLightBackgroundGray,
        appBar: AppBar(
          backgroundColor: CupertinoColors.extraLightBackgroundGray,
          actions: [
            TextButton(
              onPressed: () =>
                  ref.read(postViewModelProvider().notifier).post(context),
              child: const Text(
                '投稿',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => ref
                        .read(postViewModelProvider().notifier)
                        .onTapImage(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.extraLightBackgroundGray,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 2),
                      ),
                      width: deviceWidth / 2,
                      height: deviceWidth / 2,
                      child: state.foodImage != ''
                          ? Image.file(
                              File(state.foodImage),
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.add, size: 50),
                    ),
                  ),
                  AppPostTextField(
                    controller: controller.foodTextController,
                    hintText: 'Food Name',
                    maxLines: 1,
                  ),
                  GestureDetector(
                    onTap: () => ref
                        .read(postViewModelProvider().notifier)
                        .onTapRestaurant(),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 20,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFF6750A4)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.restaurant,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: state.restaurant == 'レストランを選択'
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AppPostTextField(
                    controller: controller.commentTextController,
                    hintText: 'Comment',
                    maxLines: 7,
                  ),
                  Text(
                    state.status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            AppLoading(loading: loading),
          ],
        ),
      ),
    );
  }
}
