import 'dart:io';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/post/provider/post_screen_state_provider.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:food_gram_app/utils/snack_bar_manager.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostScreen extends HookConsumerWidget {
  const PostScreen({
    required this.routerPath,
    super.key,
  });

  final String routerPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final textController = ref.watch(postScreenStateProvider().notifier);
    final state = ref.watch(postScreenStateProvider());
    final loading = ref.watch(loadingProvider);
    final theme = Theme.of(context);
    final restaurantTag = useState('');
    final foodTag = useState('');
    return PopScope(
      canPop: !loading,
      child: GestureDetector(
        onTap: () => primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: !loading ? Colors.white : Colors.transparent,
            title: Text(
              '投稿',
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            leading: !loading
                ? IconButton(
                    onPressed: () async {
                      primaryFocus?.unfocus();
                      await Future.delayed(Duration(milliseconds: 100));
                      context.pop();
                    },
                    icon: Icon(
                      Icons.close,
                      size: 28,
                      color: Colors.black,
                    ),
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
                            .read(postScreenStateProvider().notifier)
                            .post(
                              restaurantTag: restaurantTag.value,
                              foodTag: foodTag.value,
                            );
                        final updatedState =
                            ref.read(postScreenStateProvider());
                        if (result) {
                          context.pop(true);
                        } else {
                          openErrorSnackBar(context, updatedState.status);
                        }
                      },
                    );
                  },
                  child: Text(
                    L10n.of(context).postShareButton,
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                SizedBox.shrink(),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            primaryFocus?.unfocus();
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return AppImageModalSheet(
                                  camera: () async {
                                    await ref
                                        .read(
                                          postScreenStateProvider().notifier,
                                        )
                                        .camera();
                                    ref.read(postScreenStateProvider());
                                  },
                                  album: () async {
                                    await ref
                                        .read(
                                          postScreenStateProvider().notifier,
                                        )
                                        .album();
                                    ref.read(postScreenStateProvider());
                                  },
                                );
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
                                : const Icon(
                                    Icons.add,
                                    size: 45,
                                    color: Colors.black,
                                  ),
                          ),
                        ),
                      ),
                      Gap(28),
                      AppFoodTextField(controller: textController.food),
                      Gap(28),
                      GestureDetector(
                        onTap: () async {
                          primaryFocus?.unfocus();
                          await context.pushNamed(routerPath).then(
                            (value) {
                              if (value != null) {
                                ref
                                    .read(postScreenStateProvider().notifier)
                                    .getPlace(value as Restaurant);
                              }
                            },
                          );
                        },
                        child: ListTile(
                          contentPadding: EdgeInsets.all(5),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Icon(
                              Icons.place,
                              size: 30,
                              color: Colors.black,
                            ),
                          ),
                          trailing: state.restaurant == '場所を追加'
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                )
                              : SizedBox(),
                          title: Text(
                            state.restaurant == '場所を追加'
                                ? L10n.of(context).postRestaurantNameInputField
                                : state.restaurant,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: state.restaurant == '場所を追加'
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Gap(28),
                      AppCommentTextField(controller: textController.comment),
                      Gap(20),
                      Text(
                        L10n.of(context).restaurantCategoryList,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Gap(10),
                      Wrap(
                        spacing: 10,
                        children: restaurantCategory.map<Widget>((data) {
                          return FilterChip(
                            showCheckmark: false,
                            backgroundColor: Colors.white,
                            label: Text(data, style: TextStyle(fontSize: 24)),
                            selected: restaurantTag.value == data,
                            selectedColor: Colors.greenAccent,
                            onSelected: (value) {
                              restaurantTag.value = data;
                            },
                          );
                        }).toList(),
                      ),
                      Gap(20),
                      Text(
                        L10n.of(context).cookingCategoryList,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Gap(10),
                      Wrap(
                        spacing: 10,
                        children: foodCategory.map<Widget>((data) {
                          return FilterChip(
                            showCheckmark: false,
                            backgroundColor: Colors.white,
                            selectedColor: Colors.greenAccent,
                            label: Text(
                              data,
                              style: TextStyle(fontSize: 24),
                            ),
                            selected: foodTag.value == data,
                            onSelected: (value) {
                              foodTag.value = data;
                            },
                          );
                        }).toList(),
                      ),
                      Gap(30),
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
