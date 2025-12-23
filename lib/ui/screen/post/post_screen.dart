import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/user/services/streak_service.dart';
import 'package:food_gram_app/core/theme/style/post_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_tag.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
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
    final l10n = L10n.of(context);
    final deviceWidth = MediaQuery.of(context).size.width;
    final state = ref.watch(postViewModelProvider());
    final loading = ref.watch(loadingProvider);
    final countryTag = useState('');
    final countryText = useMemoized(
      () => ValueNotifier(
        countryTag.value.isNotEmpty
            ? getLocalizedCountryName(countryTag.value, context)
            : '',
      ),
      [countryTag.value],
    );
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
                        if (state.foodImages.isNotEmpty)
                          SizedBox(
                            height: deviceWidth / 1.7,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.foodImages.length,
                              itemBuilder: (context, index) {
                                final imagePath = state.foodImages[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: index < state.foodImages.length - 1
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
                                          child: Image.file(
                                            File(imagePath),
                                            fit: BoxFit.cover,
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
                                          state.restaurant == '場所を追加'
                                              ? l10n
                                                  .postRestaurantNameInputField
                                              : state.restaurant,
                                          overflow: TextOverflow.ellipsis,
                                          style: PostStyle.restaurant(
                                            value: state.restaurant == '場所を追加',
                                          ),
                                        ),
                                      ),
                                      if (state.restaurant == '場所を追加')
                                        const Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.black,
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
                    const Gap(12),
                    Text(
                      l10n.postCategoryTitle,
                      style: PostStyle.categoryTitle(),
                    ),
                    const Gap(4),
                    AppCountryTag(
                      countryTag: countryTag.value,
                      countryText: countryText,
                      onTagSelected: (tag) {
                        countryTag.value = tag;
                      },
                    ),
                    AppFoodTag(
                      foodTags: foodTags.value,
                      foodTexts: foodTexts,
                      onTagSelected: (tags) {
                        foodTags.value = tags;
                      },
                    ),
                    const Gap(12),
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
                        l10n.anonymousPost,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        l10n.anonymousPostDescription,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Switch(
                        value: state.isAnonymous,
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
              status: state.status,
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
                                restaurantTag: countryTag.value,
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
                        final status =
                            ref.watch(postViewModelProvider()).status;
                        SnackBarHelper().openErrorSnackBar(
                          context,
                          l10n.postError,
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
                      state.isAnonymous
                          ? l10n.anonymousShare
                          : l10n.shareButton,
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
    final l10n = L10n.of(context);
    switch (postStatus) {
      case PostStatus.errorPickImage:
        return l10n.postErrorPickImage;
      case PostStatus.error:
        return l10n.postError;
      case PostStatus.photoSuccess:
        return l10n.postPhotoSuccess;
      case PostStatus.cameraPermission:
        return l10n.postCameraPermission;
      case PostStatus.albumPermission:
        return l10n.postAlbumPermission;
      case PostStatus.success:
        return l10n.postSuccess;
      case PostStatus.loading:
        return 'Loading...';
      case PostStatus.missingPhoto:
        return l10n.postMissingPhoto;
      case PostStatus.missingFoodName:
        return l10n.postMissingFoodName;
      case PostStatus.missingRestaurant:
        return l10n.postMissingRestaurant;
      case PostStatus.initial:
        return 'Loading...';
    }
  }
}
