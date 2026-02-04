import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/theme/style/edit_post_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_tag.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/dialog/app_maybe_not_food_dialog.dart';
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
    final t = Translations.of(context);
    final deviceWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final previewWidth = (deviceWidth * 0.85 * devicePixelRatio).round();
    final previewHeight = (deviceWidth / 1.7 * devicePixelRatio).round();
    final loading = ref.watch(loadingProvider);
    final status =
        ref.watch(editPostViewModelProvider().select((s) => s.status));
    final existingImagePaths = ref
        .watch(editPostViewModelProvider().select((s) => s.existingImagePaths));
    final foodImages =
        ref.watch(editPostViewModelProvider().select((s) => s.foodImages));
    final restaurantName =
        ref.watch(editPostViewModelProvider().select((s) => s.restaurant));
    final isAnonymous =
        ref.watch(editPostViewModelProvider().select((s) => s.isAnonymous));
    final star = ref.watch(editPostViewModelProvider().select((s) => s.star));
    final viewModel = ref.watch(editPostViewModelProvider().notifier);
    final countryTag = useState(posts.restaurantTag);
    final foodTags = useState<List<String>>(
      posts.foodTag.isNotEmpty ? posts.foodTag.split(',') : [],
    );
    final foodTexts = useMemoized(
      () => ValueNotifier<List<String>>(
        foodTags.value
            .map((tag) => getLocalizedFoodName(tag, context))
            .toList(),
      ),
      [foodTags.value],
    );
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
    useEffect(
      () {
        if (status == EditStatus.maybeNotFood.name) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!context.mounted) {
              return;
            }
            final images = ref.read(editPostViewModelProvider()).foodImages;
            final index = images.length;
            await showMaybeNotFoodDialog(
              context: context,
              title: t.maybeNotFoodDialog.title,
              text: _maybeNotFoodDialogText(context, index),
              onContinue: () {
                ref.read(editPostViewModelProvider().notifier).resetStatus();
              },
              onDelete: () {
                final images = ref.read(editPostViewModelProvider()).foodImages;
                if (images.isNotEmpty) {
                  ref
                      .read(editPostViewModelProvider().notifier)
                      .removeImage(images.last);
                }
                ref.read(editPostViewModelProvider().notifier).resetStatus();
              },
            );
          });
        }
        return null;
      },
      [status],
    );
    final supabase = ref.watch(supabaseProvider);
    // 最初の画像のURLを取得（既存の表示用）
    final firstImagePath =
        posts.foodImage.isNotEmpty ? posts.foodImage.split(',').first : '';
    final foodImageUrl = firstImagePath.isNotEmpty
        ? supabase.storage.from('food').getPublicUrl(firstImagePath)
        : '';
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: !loading ? Colors.white : Colors.transparent,
          title: Text(
            t.edit.editTitle,
            style: EditPostStyle.editTitle(),
          ),
          centerTitle: true,
          leading: !loading
              ? IconButton(
                  onPressed: () async {
                    primaryFocus?.unfocus();
                    await Future<void>.delayed(
                      const Duration(milliseconds: 100),
                    );
                    context.pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 28,
                    color: Colors.black,
                  ),
                )
              : const SizedBox(),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    Column(
                      children: [
                        // 既存の画像（サーバーから読み込んだもの）
                        if (existingImagePaths.isNotEmpty)
                          SizedBox(
                            height: deviceWidth / 1.7,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: existingImagePaths.length,
                              itemBuilder: (context, index) {
                                final imagePath = existingImagePaths[index];
                                final existingImageUrl = supabase.storage
                                    .from('food')
                                    .getPublicUrl(imagePath);
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: index < existingImagePaths.length - 1
                                        ? 12
                                        : 0,
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border:
                                              Border.all(color: Colors.black87),
                                        ),
                                        width: deviceWidth * 0.85,
                                        height: deviceWidth / 1.7,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: existingImageUrl,
                                            fit: BoxFit.cover,
                                            memCacheWidth: previewWidth,
                                            memCacheHeight: previewHeight,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            ref
                                                .read(
                                                  editPostViewModelProvider()
                                                      .notifier,
                                                )
                                                .removeExistingImage(imagePath);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        // 新しく追加した画像
                        if (foodImages.isNotEmpty)
                          SizedBox(
                            height: deviceWidth / 1.7,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: foodImages.length,
                              itemBuilder: (context, index) {
                                final imagePath = foodImages[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right:
                                        index < foodImages.length - 1 ? 12 : 0,
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border:
                                              Border.all(color: Colors.black87),
                                        ),
                                        width: deviceWidth * 0.85,
                                        height: deviceWidth / 1.7,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.file(
                                            File(imagePath),
                                            fit: BoxFit.cover,
                                            cacheWidth: previewWidth,
                                            cacheHeight: previewHeight,
                                            filterQuality: FilterQuality.high,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            ref
                                                .read(
                                                  editPostViewModelProvider()
                                                      .notifier,
                                                )
                                                .removeImage(imagePath);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        // 画像追加ボタン（画像がない場合のみ表示）
                        if (existingImagePaths.isEmpty && foodImages.isEmpty)
                          GestureDetector(
                            onTap: () async {
                              primaryFocus?.unfocus();
                              await showModalBottomSheet<void>(
                                context: context,
                                builder: (context) {
                                  return AppPostImageModalSheet(
                                    camera: () async {
                                      await ref
                                          .read(
                                            editPostViewModelProvider()
                                                .notifier,
                                          )
                                          .camera();
                                    },
                                    album: () async {
                                      await ref
                                          .read(
                                            editPostViewModelProvider()
                                                .notifier,
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
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black87),
                              ),
                              width: deviceWidth,
                              height: deviceWidth / 1.7,
                              child: foodImageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: foodImageUrl,
                                        fit: BoxFit.cover,
                                        memCacheWidth: previewWidth,
                                        memCacheHeight: previewHeight,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.add,
                                      size: 40,
                                      color: Colors.black,
                                    ),
                            ),
                          ),
                      ],
                    ),
                    const Gap(20),
                    AppFoodTextField(controller: viewModel.foodController),
                    const Gap(12),
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
                              size: 28,
                              color: Colors.black,
                            ),
                            const Gap(10),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    side:
                                        const BorderSide(color: Colors.black87),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  title: Row(
                                    children: [
                                      const Gap(16),
                                      Expanded(
                                        child: Text(
                                          restaurantName,
                                          overflow: TextOverflow.ellipsis,
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
                    const Gap(6),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          const Gap(5),
                          const Icon(
                            Icons.label,
                            size: 28,
                            color: Colors.black,
                          ),
                          const Gap(5),
                          Expanded(
                            child: AppFoodTag(
                              foodTags: foodTags.value,
                              foodTexts: foodTexts,
                              onTagSelected: (tags) {
                                foodTags.value = tags;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(6),
                    Text(
                      t.post.ratingLabel,
                      style: EditPostStyle.category(),
                    ),
                    const Gap(6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          RatingBar.builder(
                            initialRating: star,
                            allowHalfRating: true,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 2),
                            unratedColor: Colors.grey.shade300,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              ref
                                  .read(editPostViewModelProvider().notifier)
                                  .setStar(rating);
                            },
                          ),
                          const Spacer(),
                          Text(
                            star.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    AppCommentTextField(
                      controller: viewModel.commentController,
                    ),
                    const Gap(12),
                    ListTile(
                      dense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      leading: const Icon(
                        Icons.visibility_off,
                        size: 28,
                        color: Colors.black,
                      ),
                      title: Text(
                        t.anonymous.post,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        t.anonymous.postDescription,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Switch(
                        value: isAnonymous,
                        activeThumbColor: Colors.blue[600],
                        activeTrackColor: Colors.blue[100],
                        inactiveTrackColor: Colors.grey[300],
                        inactiveThumbColor: Colors.white,
                        onChanged: (value) {
                          ref
                              .read(editPostViewModelProvider().notifier)
                              .setAnonymous(value: value);
                        },
                      ),
                    ),
                    const Gap(20),
                  ],
                ),
              ),
            ),
            AppProcessLoading(
              loading: loading,
              status: status,
            ),
          ],
        ),
        bottomNavigationBar: !loading
            ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final foodTagString = foodTags.value.isEmpty
                          ? ''
                          : foodTags.value.join(',');
                      final isSuccess = await ref
                          .read(editPostViewModelProvider().notifier)
                          .update(
                            restaurantTag: countryTag.value,
                            foodTag: foodTagString,
                          );
                      if (isSuccess) {
                        while (loading) {
                          await Future<void>.delayed(
                            const Duration(milliseconds: 100),
                          );
                        }
                        final updatePosts =
                            ref.read(editPostViewModelProvider()).posts;
                        if (updatePosts != null) {
                          context.pop(updatePosts);
                        }
                      } else {
                        SnackBarHelper().openErrorSnackBar(
                          context,
                          t.post.error,
                          _getLocalizedStatus(context, status),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(
                      isAnonymous ? t.anonymous.update : t.edit.updateButton,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            : null,
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
        return Translations.of(context).post.missingInfo;
      case EditStatus.error:
        return Translations.of(context).post.error;
      case EditStatus.photoSuccess:
        return Translations.of(context).post.photoSuccess;
      case EditStatus.cameraPermission:
        return Translations.of(context).post.cameraPermission;
      case EditStatus.albumPermission:
        return Translations.of(context).post.albumPermission;
      case EditStatus.success:
        return Translations.of(context).post.success;
      case EditStatus.loading:
        return 'Loading...';
      case EditStatus.initial:
        return '';
      case EditStatus.maybeNotFood:
        return Translations.of(context).maybeNotFoodDialog.title;
    }
  }
}

String _maybeNotFoodDialogText(BuildContext context, int index) {
  final t = Translations.of(context);
  return t.maybeNotFoodDialog.text.replaceFirst('{index}', index.toString());
}
