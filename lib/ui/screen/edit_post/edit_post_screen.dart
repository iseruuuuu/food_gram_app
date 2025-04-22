import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/theme/style/edit_post_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_post_category_widget.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_post_image_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/edit_post/edit_post_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditPostScreen extends HookConsumerWidget {
  const EditPostScreen({
    required this.posts,
    super.key,
  });

  final Posts posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final deviceWidth = MediaQuery.of(context).size.width;
    final loading = ref.watch(loadingProvider);
    final countryTag = useState(posts.restaurantTag);
    final foodTag = useState(posts.foodTag);
    final state = ref.watch(editPostViewModelProvider());
    final viewModel = ref.watch(editPostViewModelProvider().notifier);
    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.initializeWithPosts(posts);
          return;
        });
        return null;
      },
      [posts],
    );
    final supabase = ref.watch(supabaseProvider);
    final foodImageUrl =
        supabase.storage.from('food').getPublicUrl(posts.foodImage);
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: !loading ? Colors.white : Colors.transparent,
          title: Text(
            l10n.editTitle,
            style: EditPostStyle.editTitle(),
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
                  final result = await ref
                      .read(editPostViewModelProvider().notifier)
                      .update(
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
                child: Text(
                  l10n.editUpdateButton,
                  style: EditPostStyle.editButton(),
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
                        onTap: () async {
                          primaryFocus?.unfocus();
                          await showModalBottomSheet<void>(
                            context: context,
                            builder: (context) {
                              return AppPostImageModalSheet(
                                camera: () async {
                                  await ref
                                      .read(
                                        editPostViewModelProvider().notifier,
                                      )
                                      .camera();
                                },
                                album: () async {
                                  await ref
                                      .read(
                                        editPostViewModelProvider().notifier,
                                      )
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
                              : CachedNetworkImage(
                                  imageUrl: foodImageUrl,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    const Gap(28),
                    AppFoodTextField(
                      controller: viewModel.foodController,
                    ),
                    const Gap(18),
                    GestureDetector(
                      onTap: () async {
                        primaryFocus?.unfocus();
                        final result = await context
                            .pushNamed(RouterPath.timeLineRestaurant);
                        if (result != null) {
                          ref
                              .read(editPostViewModelProvider().notifier)
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
                                title: FittedBox(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Text(
                                          state.restaurant,
                                          style: EditPostStyle.restaurant(),
                                        ),
                                      ),
                                    ],
                                  ),
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
                      style: EditPostStyle.category(),
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
                      controller: viewModel.commentController,
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
    final postStatus = EditStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => EditStatus.initial,
    );
    switch (postStatus) {
      case EditStatus.missingInfo:
        return L10n.of(context).postMissingInfo;
      case EditStatus.error:
        return L10n.of(context).postError;
      case EditStatus.photoSuccess:
        return L10n.of(context).postPhotoSuccess;
      case EditStatus.cameraPermission:
        return L10n.of(context).postCameraPermission;
      case EditStatus.albumPermission:
        return L10n.of(context).postAlbumPermission;
      case EditStatus.success:
        return L10n.of(context).postSuccess;
      case EditStatus.loading:
        return 'Loading...';
      case EditStatus.initial:
        return '';
    }
  }
}
