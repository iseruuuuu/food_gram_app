import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/model/restaurant.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_post_text_field.dart';
import 'package:food_gram_app/ui/screen/post/post_view_model.dart';
import 'package:food_gram_app/utils/mixin/show_modal_bottom_sheet_mixin.dart';
import 'package:food_gram_app/utils/mixin/snack_bar_mixin.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:go_router/go_router.dart';

class PostScreen extends ConsumerWidget
    with ShowModalBottomSheetMixin, SnackBarMixin {
  const PostScreen({
    required this.routerPath,
    super.key,
  });

  final String routerPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final controller = ref.watch(postViewModelProvider().notifier);
    final state = ref.watch(postViewModelProvider());
    final loading = ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: !loading ? Colors.white : Colors.transparent,
          automaticallyImplyLeading: !loading,
          actions: [
            if (!loading)
              TextButton(
                onPressed: () async {
                  final result =
                      await ref.read(postViewModelProvider().notifier).post();
                  final updatedState = ref.read(postViewModelProvider());
                  if (result) {
                    context.pop(true);
                  } else {
                    openSnackBar(context, updatedState.status);
                  }
                },
                child: const Text(
                  '投稿',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              )
            else
              SizedBox(),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      onTapImage(
                        context: context,
                        camera:
                            ref.read(postViewModelProvider().notifier).camera,
                        album: ref.read(postViewModelProvider().notifier).album,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                    hintText: '食べたもの',
                    maxLines: 1,
                  ),
                  GestureDetector(
                    onTap: () async {
                      primaryFocus?.unfocus();
                      await context.pushNamed(routerPath).then(
                        (value) {
                          if (value != null) {
                            ref
                                .read(postViewModelProvider().notifier)
                                .getPlace(value as Restaurant);
                          }
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
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
                                  color: state.restaurant == '食べた場所'
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  AppPostCommentTextField(
                    controller: controller.commentTextController,
                    hintText: 'コメント',
                  ),
                ],
              ),
            ),
            AppLoading(
              loading: loading,
              status: state.status,
            ),
          ],
        ),
      ),
    );
  }
}
