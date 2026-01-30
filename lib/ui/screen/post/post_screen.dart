import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/user/services/streak_service.dart';
import 'package:food_gram_app/core/theme/style/post_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/app_tag.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/dialog/app_maybe_not_food_dialog.dart';
import 'package:food_gram_app/ui/component/dialog/app_streak_dialog.dart';
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
    final t = Translations.of(context);
    final deviceWidth = MediaQuery.of(context).size.width;
    final status = ref.watch(postViewModelProvider().select((s) => s.status));
    final foodImages =
        ref.watch(postViewModelProvider().select((s) => s.foodImages));
    final restaurantName =
        ref.watch(postViewModelProvider().select((s) => s.restaurant));
    final isAnonymous =
        ref.watch(postViewModelProvider().select((s) => s.isAnonymous));
    final star = ref.watch(postViewModelProvider().select((s) => s.star));
    final loading = ref.watch(loadingProvider);
    final foodTags = useState<List<String>>([]);
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
    useEffect(
      () {
        if (status == PostStatus.maybeNotFood.name) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!context.mounted) {
              return;
            }
            await showMaybeNotFoodDialog(
              context: context,
              onContinue: () {
                ref.read(postViewModelProvider().notifier).resetStatus();
              },
              onDelete: () {
                final images = ref.read(postViewModelProvider()).foodImages;
                if (images.isNotEmpty) {
                  ref
                      .read(postViewModelProvider().notifier)
                      .removeImage(images.last);
                }
                ref.read(postViewModelProvider().notifier).resetStatus();
              },
            );
          });
        }
        return null;
      },
      [status],
    );
    // プレビューサイズに合わせて縮小デコード（物理解像度で指定）
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final previewWidth = (deviceWidth * 0.85 * devicePixelRatio).round();
    final previewHeight = (deviceWidth / 1.7 * devicePixelRatio).round();
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: !loading ? Colors.white : Colors.transparent,
          title: Text(t.postTitle, style: PostStyle.title()),
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
                  icon: const Icon(Icons.close, size: 28, color: Colors.black),
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
                    Column(
                      children: [
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
                                                  postViewModelProvider()
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
                          )
                        else
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
                                            postViewModelProvider().notifier,
                                          )
                                          .camera();
                                    },
                                    album: () async {
                                      await ref
                                          .read(
                                            postViewModelProvider().notifier,
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
                              child: const Icon(
                                Icons.add,
                                size: 40,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Gap(20),
                    AppFoodTextField(
                      controller: ref
                          .read(postViewModelProvider().notifier)
                          .foodController,
                    ),
                    const Gap(12),
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
                                    side: const BorderSide(
                                      color: Colors.black87,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  title: Row(
                                    children: [
                                      const Gap(16),
                                      Expanded(
                                        child: Text(
                                          restaurantName == '場所を追加'
                                              ? t
                                                  .postRestaurantNameInputField
                                              : restaurantName,
                                          overflow: TextOverflow.ellipsis,
                                          style: PostStyle.restaurant(
                                            value: restaurantName == '場所を追加',
                                          ),
                                        ),
                                      ),
                                      if (restaurantName == '場所を追加')
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 20,
                                            ),
                                            Gap(10),
                                          ],
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
                      t.postRatingLabel,
                      style: PostStyle.categoryTitle(),
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
                                  .read(postViewModelProvider().notifier)
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
                      controller: ref
                          .read(postViewModelProvider().notifier)
                          .commentController,
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
                        t.anonymousPost,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        t.anonymousPostDescription,
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
                              .read(postViewModelProvider().notifier)
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
                      final result =
                          await ref.read(postViewModelProvider().notifier).post(
                                restaurantTag: '',
                                foodTag: foodTagString,
                              );
                      if (result) {
                        // ストリークを更新
                        final streakService =
                            ref.read(streakServiceProvider.notifier);
                        final streakResult = await streakService.updateStreak();
                        // ストリークが更新された場合のみダイアログを表示
                        if (streakResult.isUpdated) {
                          // ダイアログを表示（初回投稿かどうかを判定）
                          final isFirstTime = streakResult.newStreakWeeks == 1;
                          if (context.mounted) {
                            await showStreakDialog(
                              context: context,
                              streakWeeks: streakResult.newStreakWeeks,
                              isFirstTime: isFirstTime,
                            );
                          }
                        }
                        if (context.mounted) {
                          context.pop(true);
                        }
                      } else {
                        SnackBarHelper().openErrorSnackBar(
                          context,
                          t.postError,
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
                      isAnonymous ? t.anonymousShare : t.shareButton,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  String _getLocalizedStatus(BuildContext context, String status) {
    final postStatus = PostStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => PostStatus.initial,
    );
    final t = Translations.of(context);
    switch (postStatus) {
      case PostStatus.errorPickImage:
        return t.postErrorPickImage;
      case PostStatus.error:
        return t.postError;
      case PostStatus.photoSuccess:
        return t.postPhotoSuccess;
      case PostStatus.cameraPermission:
        return t.postCameraPermission;
      case PostStatus.albumPermission:
        return t.postAlbumPermission;
      case PostStatus.success:
        return t.postSuccess;
      case PostStatus.loading:
        return 'Loading...';
      case PostStatus.missingPhoto:
        return t.postMissingPhoto;
      case PostStatus.missingFoodName:
        return t.postMissingFoodName;
      case PostStatus.missingRestaurant:
        return t.postMissingRestaurant;
      case PostStatus.maybeNotFood:
        return t.maybeNotFoodDialogTitle;
      case PostStatus.initial:
        return 'Loading...';
    }
  }
}
