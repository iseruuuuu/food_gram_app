import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_post_image_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/post/component/post_category_widget.dart';
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
    final l10n = L10n.of(context);
    final deviceWidth = MediaQuery.of(context).size.width;
    final state = ref.watch(postScreenStateProvider());
    final notifier = ref.read(postScreenStateProvider().notifier);
    final loading = ref.watch(loadingProvider);
    final countryTag = useState('');
    final foodTag = useState('');
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: !loading ? Colors.white : Colors.transparent,
          title: Text(
            l10n.postTitle,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
          centerTitle: true,
          leading: !loading
              ? IconButton(
                  onPressed: () async {
                    primaryFocus?.unfocus();
                    await Future.delayed(const Duration(milliseconds: 100));
                    context.pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 28,
                    color: Colors.black,
                  ),
                )
              : const SizedBox(),
          actions: [
            if (!loading)
              TextButton(
                onPressed: () async {
                  final result = await notifier.post(
                    restaurantTag: countryTag.value,
                    foodTag: foodTag.value,
                  );
                  if (result) {
                    context.pop(true);
                  } else {
                    openErrorSnackBar(
                      context,
                      state.status,
                      l10n.postError,
                    );
                  }
                },
                child: Text(
                  l10n.postShareButton,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
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
                              return AppPostImageModalSheet(
                                camera: () async {
                                  await notifier.camera();
                                },
                                album: () async {
                                  await notifier.album();
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
                          child: state.foodImage.isNotEmpty
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
                    const Gap(28),
                    AppFoodTextField(controller: notifier.food),
                    const Gap(28),
                    GestureDetector(
                      onTap: () async {
                        primaryFocus?.unfocus();
                        final result = await context.pushNamed(routerPath);
                        if (result != null) {
                          notifier.getPlace(result as Restaurant);
                        }
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(5),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.black26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: const Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Icon(
                            Icons.place,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                        trailing: state.restaurant == '場所を追加'
                            ? const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              )
                            : null,
                        title: Text(
                          state.restaurant == '場所を追加'
                              ? l10n.postRestaurantNameInputField
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
                    const Gap(28),
                    AppCommentTextField(controller: notifier.comment),
                    const Gap(20),
                    Text(
                      l10n.postCategoryTitle,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Gap(20),
                    Row(
                      children: [
                        PostCategoryWidget(
                          tag: countryTag,
                          category: countryCategory,
                          title: l10n.postCountryCategory,
                        ),
                        const Gap(30),
                        PostCategoryWidget(
                          tag: foodTag,
                          category: foodCategory,
                          title: l10n.postCuisineCategory,
                        ),
                      ],
                    ),
                    const Gap(30),
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
    );
  }
}
