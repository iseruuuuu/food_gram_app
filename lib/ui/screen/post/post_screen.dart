import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/theme/style/post_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_post_category_widget.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_post_image_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/post/post_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostScreen extends HookConsumerWidget {
  const PostScreen({
    required this.routerPath,
    this.restaurant,
    super.key,
  });

  final String routerPath;
  final Restaurant? restaurant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final deviceWidth = MediaQuery.of(context).size.width;
    final state = ref.watch(postViewModelProvider());
    final loading = ref.watch(loadingProvider);
    final countryTag = useState('');
    final foodTag = useState('');
    useEffect(
      () {
        if (restaurant != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(postViewModelProvider().notifier)
                .loadRestaurant(restaurant);
          });
        }
        return null;
      },
      [restaurant],
    );
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: !loading ? Colors.white : Colors.transparent,
          title: Text(l10n.postTitle, style: PostStyle.title()),
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
                  final result =
                      await ref.read(postViewModelProvider().notifier).post(
                            restaurantTag: countryTag.value,
                            foodTag: foodTag.value,
                          );
                  if (result) {
                    context.pop(true);
                  } else {
                    SnackBarHelper().openErrorSnackBar(
                      context,
                      l10n.postError,
                      _getLocalizedStatus(context, state.status),
                    );
                  }
                },
                child: Text(l10n.postShareButton, style: PostStyle.share()),
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
                                  await ref
                                      .read(postViewModelProvider().notifier)
                                      .camera();
                                },
                                album: () async {
                                  await ref
                                      .read(postViewModelProvider().notifier)
                                      .album();
                                },
                              );
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(),
                          ),
                          width: deviceWidth,
                          height: deviceWidth / 1.7,
                          child: state.foodImage.isNotEmpty
                              ? Image.file(
                                  File(state.foodImage),
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.add,
                                  size: 40,
                                  color: Colors.black,
                                ),
                        ),
                      ),
                    ),
                    const Gap(28),
                    AppFoodTextField(
                      controller: ref
                          .read(postViewModelProvider().notifier)
                          .foodController,
                    ),
                    const Gap(18),
                    GestureDetector(
                      onTap: () async {
                        primaryFocus?.unfocus();
                        final result = await context.pushNamed(routerPath);
                        if (result != null) {
                          ref
                              .read(postViewModelProvider().notifier)
                              .getPlace(result as Restaurant);
                        }
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            const Gap(5),
                            const Icon(
                              Icons.place,
                              size: 30,
                              color: Colors.black,
                            ),
                            const Gap(10),
                            Expanded(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                title: Row(
                                  children: [
                                    const Gap(16),
                                    Text(
                                      state.restaurant == '場所を追加'
                                          ? l10n.postRestaurantNameInputField
                                          : state.restaurant,
                                      overflow: TextOverflow.ellipsis,
                                      style: PostStyle.restaurant(
                                        value: state.restaurant == '場所を追加',
                                      ),
                                    ),
                                    const Spacer(),
                                    if (state.restaurant == '場所を追加')
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.black,
                                            size: 24,
                                          ),
                                          Gap(10),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(18),
                    Text(
                      l10n.postCategoryTitle,
                      style: PostStyle.categoryTitle(),
                    ),
                    const Gap(12),
                    Row(
                      children: [
                        AppPostCountryCategoryWidget(
                          tag: countryTag,
                          title: l10n.postCountryCategory,
                        ),
                        const Gap(30),
                        AppPostFoodCategoryWidget(
                          tag: foodTag,
                          title: l10n.postCuisineCategory,
                        ),
                      ],
                    ),
                    const Gap(30),
                    AppCommentTextField(
                      controller: ref
                          .read(postViewModelProvider().notifier)
                          .commentController,
                    ),
                    const Gap(20),
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

  String _getLocalizedStatus(BuildContext context, String status) {
    final postStatus = PostStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => PostStatus.initial,
    );
    switch (postStatus) {
      case PostStatus.missingInfo:
        return L10n.of(context).postMissingInfo;
      case PostStatus.error:
        return L10n.of(context).postError;
      case PostStatus.photoSuccess:
        return L10n.of(context).postPhotoSuccess;
      case PostStatus.cameraPermission:
        return L10n.of(context).postCameraPermission;
      case PostStatus.albumPermission:
        return L10n.of(context).postAlbumPermission;
      case PostStatus.success:
        return L10n.of(context).postSuccess;
      case PostStatus.loading:
        return 'Loading...';
      case PostStatus.initial:
        return '';
    }
  }
}
