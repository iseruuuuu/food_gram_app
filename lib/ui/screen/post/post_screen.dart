import 'dart:io';

import 'package:easy_debounce/easy_debounce.dart';
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
    return PopScope(
      canPop: !loading,
      child: GestureDetector(
        onTap: () => primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: !loading ? Colors.white : Colors.transparent,
            leading: !loading
                ? IconButton(
                    onPressed: () async {
                      primaryFocus?.unfocus();
                      await Future.delayed(Duration(milliseconds: 100));
                      context.pop();
                    },
                    icon: Icon(Icons.close),
                  )
                : SizedBox(),
            actions: [
              if (!loading)
                TextButton(
                  onPressed: () {
                    EasyDebounce.debounce(
                      'post',
                      Duration(seconds: 1),
                      () async {
                        final result = await ref
                            .read(postViewModelProvider().notifier)
                            .post();
                        final updatedState = ref.read(postViewModelProvider());
                        if (result) {
                          context.pop(true);
                        } else {
                          openSnackBar(context, updatedState.status);
                        }
                      },
                    );
                  },
                  child: const Text(
                    'シェア',
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          onTapImage(
                            context: context,
                            camera: () async {
                              final result = await ref
                                  .read(postViewModelProvider().notifier)
                                  .camera();
                              final updatedState =
                                  ref.read(postViewModelProvider());
                              if (!result) {
                                hideSnackBar(context);
                                openSnackBar(context, updatedState.status);
                              }
                            },
                            album: () async {
                              final result = await ref
                                  .read(postViewModelProvider().notifier)
                                  .album();
                              final updatedState =
                                  ref.read(postViewModelProvider());
                              if (!result) {
                                hideSnackBar(context);
                                openSnackBar(context, updatedState.status);
                              }
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 2),
                          ),
                          width: deviceWidth / 1.8,
                          height: deviceWidth / 1.8,
                          child: state.foodImage != ''
                              ? Image.file(
                                  File(state.foodImage),
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.add, size: 45),
                        ),
                      ),
                      SizedBox(height: 50),
                      Divider(),
                      AppPostTextField(
                        controller: controller.foodTextController,
                        hintText: '食べたもの',
                        maxLines: 1,
                      ),
                      Divider(),
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
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: 50,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(Icons.place, size: 30),
                              ),
                              Text(
                                state.restaurant,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: state.restaurant == '場所を追加'
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              Spacer(),
                              if (state.restaurant == '場所を追加')
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                )
                              else
                                SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                      AppPostCommentTextField(
                        controller: controller.commentTextController,
                        hintText: 'コメント',
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ),
              AppLoading(
                loading: loading,
                status: state.status,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
