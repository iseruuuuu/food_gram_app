import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/review/in_app_review_service.dart';
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
    // 複数画像編集で2枚目以降も開くため、常に有効な context（build の context）を渡す
    final navigatorContext = context;
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deviceWidth = MediaQuery.of(context).size.width;
    final postState = ref.watch(
      postViewModelProvider().select(
        (s) => (
          status: s.status,
          foodImages: s.foodImages,
          restaurant: s.restaurant,
          isAnonymous: s.isAnonymous,
          star: s.star,
          priceCurrency: s.priceCurrency,
        ),
      ),
    );
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
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (restaurant != null) {
            ref
                .read(postViewModelProvider().notifier)
                .loadRestaurant(restaurant);
          }
          final draft = await ref
              .read(postViewModelProvider().notifier)
              .loadSavedDraft();
          if (!context.mounted) {
            return;
          }
          if (draft != null && draft.hasRestorableContent) {
            ref.read(postViewModelProvider().notifier).applyDraft(
                  draft,
                  applyRestaurant: restaurant == null,
                );
            foodTags.value = List<String>.from(draft.foodTags);
            SnackBarHelper().openSuccessSnackBar(
              context,
              t.post.title,
              t.post.draftRestored,
            );
          }
        });
        return null;
      },
      [restaurant],
    );
    useEffect(
      () {
        if (postState.status == PostStatus.maybeNotFood.name) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!context.mounted) {
              return;
            }
            final images = ref.read(postViewModelProvider()).foodImages;
            final index = images.length;
            await showMaybeNotFoodDialog(
              context: context,
              title: Translations.of(context).maybeNotFoodDialog.title,
              text: _maybeNotFoodDialogText(context, index),
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
      [postState.status],
    );
    // プレビューサイズに合わせて縮小デコード（物理解像度で指定）
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final previewWidth = (deviceWidth * 0.85 * devicePixelRatio).round();
    final previewHeight = (deviceWidth / 1.7 * devicePixelRatio).round();
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Theme.of(context).colorScheme.surface,
          title: Text(t.post.title, style: PostStyle.title(context)),
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
                  icon: Icon(
                    Icons.close,
                    size: 28,
                    color: Theme.of(context).colorScheme.onSurface,
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
                    Column(
                      children: [
                        if (postState.foodImages.isNotEmpty)
                          SizedBox(
                            height: deviceWidth / 1.7,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: postState.foodImages.length,
                              itemBuilder: (context, index) {
                                final imagePath = postState.foodImages[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right:
                                        index < postState.foodImages.length - 1
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
                          Builder(
                            builder: (context) {
                              final isDark = Theme.of(context).brightness ==
                                  Brightness.dark;
                              final placeholderBg =
                                  isDark ? Colors.black : Colors.white;
                              final placeholderBorder =
                                  isDark ? Colors.white54 : Colors.black87;
                              final plusIconColor =
                                  isDark ? Colors.white : Colors.black;
                              return GestureDetector(
                                onTap: () async {
                                  primaryFocus?.unfocus();
                                  await showModalBottomSheet<void>(
                                    context: navigatorContext,
                                    builder: (_) {
                                      return AppPostImageModalSheet(
                                        camera: () async {
                                          await ref
                                              .read(
                                                postViewModelProvider()
                                                    .notifier,
                                              )
                                              .camera(navigatorContext);
                                        },
                                        album: () async {
                                          await ref
                                              .read(
                                                postViewModelProvider()
                                                    .notifier,
                                              )
                                              .album(navigatorContext);
                                        },
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: placeholderBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: placeholderBorder),
                                  ),
                                  width: deviceWidth,
                                  height: deviceWidth / 1.7,
                                  child: Icon(
                                    Icons.add,
                                    size: 40,
                                    color: plusIconColor,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const Gap(20),
                    AppFoodTextField(
                      controller: ref
                          .read(postViewModelProvider().notifier)
                          .foodController,
                    ),
                    const Gap(8),
                    Builder(
                      builder: (context) {
                        final scheme = Theme.of(context).colorScheme;
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Row(
                            children: [
                              const Gap(5),
                              Icon(
                                Icons.place,
                                size: 28,
                                color: scheme.onSurface,
                              ),
                              const Gap(10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    primaryFocus?.unfocus();
                                    final result =
                                        await context.pushNamed(routerPath);
                                    if (result != null) {
                                      ref
                                          .read(
                                            postViewModelProvider().notifier,
                                          )
                                          .getPlace(result as Restaurant);
                                    }
                                  },
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: scheme.surface,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: scheme.outlineVariant,
                                      ),
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              postState.restaurant == '場所を追加'
                                                  ? t.post
                                                      .restaurantNameInputField
                                                  : postState.restaurant,
                                              overflow: TextOverflow.ellipsis,
                                              style: PostStyle.restaurant(
                                                context,
                                                value: postState.restaurant ==
                                                    '場所を追加',
                                              ),
                                            ),
                                          ),
                                          if (postState.restaurant == '場所を追加')
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 20,
                                              color: scheme.onSurface,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Gap(12),
                    Text(
                      t.post.optionalExtrasTitle,
                      style: PostStyle.categoryTitle(context),
                    ),
                    const Gap(12),
                    Builder(
                      builder: (context) {
                        final scheme = Theme.of(context).colorScheme;
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: Row(
                            children: [
                              const Gap(5),
                              Icon(
                                Icons.label,
                                size: 28,
                                color: scheme.onSurface,
                              ),
                              const Gap(10),
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
                        );
                      },
                    ),
                    const Gap(8),
                    AppPostPriceInputRow(
                      controller: ref
                          .read(postViewModelProvider().notifier)
                          .priceController,
                      currencyCode: postState.priceCurrency,
                      onCurrencyChanged: (code) {
                        ref
                            .read(postViewModelProvider().notifier)
                            .setPriceCurrency(code);
                      },
                    ),
                    const Gap(12),
                    Text(
                      t.post.ratingLabel,
                      style: PostStyle.categoryTitle(context),
                    ),
                    const Gap(6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          KeyedSubtree(
                            key: ValueKey(postState.star),
                            child: RatingBar.builder(
                              initialRating: postState.star,
                              allowHalfRating: true,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              unratedColor: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
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
                          ),
                          const Spacer(),
                          Text(
                            postState.star.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
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
                      leading: Icon(
                        Icons.visibility_off,
                        size: 28,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      title: Text(
                        t.anonymous.post,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        t.anonymous.postDescription,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Switch(
                        value: postState.isAnonymous,
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
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
              status: postState.status,
            ),
          ],
        ),
        bottomNavigationBar: !loading
            ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () async {
                          primaryFocus?.unfocus();
                          await ref
                              .read(postViewModelProvider().notifier)
                              .saveDraft(foodTags: foodTags.value);
                          if (context.mounted) {
                            SnackBarHelper().openSuccessSnackBar(
                              context,
                              t.post.saveDraft,
                              t.post.draftSaved,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          t.post.saveDraft,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          final foodTagString = foodTags.value.isEmpty
                              ? ''
                              : foodTags.value.join(',');
                          final result = await ref
                              .read(postViewModelProvider().notifier)
                              .post(
                                foodTag: foodTagString,
                                locale: Localizations.localeOf(context),
                              );
                          if (!context.mounted) {
                            return;
                          }
                          if (result) {
                            // ストリークを更新
                            final streakService =
                                ref.read(streakServiceProvider.notifier);
                            final streakResult =
                                await streakService.updateStreak();
                            if (!context.mounted) {
                              return;
                            }
                            // ストリークが更新された場合のみダイアログを表示
                            if (streakResult.isUpdated) {
                              // ダイアログを表示（初回投稿かどうかを判定）
                              final isFirstTime =
                                  streakResult.newStreakWeeks == 1;
                              // ストリークの節目（3週、5週、10週）を判定
                              final milestoneWeeks = [3, 5, 10];
                              final isMilestone = milestoneWeeks
                                  .contains(streakResult.newStreakWeeks);

                              await showStreakDialog(
                                context: context,
                                streakWeeks: streakResult.newStreakWeeks,
                                isFirstTime: isFirstTime,
                              );

                              // 初回投稿またはストリークの節目の場合、レビューを表示
                              if (isFirstTime || isMilestone) {
                                if (!context.mounted) {
                                  return;
                                }
                                // ストリークダイアログ表示後、少し間を置いてからレビューを表示
                                await Future<void>.delayed(
                                  const Duration(seconds: 2),
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                final reviewService = InAppReviewService();
                                await reviewService.requestReview();
                              }
                            }
                            if (context.mounted) {
                              context.pop(true);
                            }
                          } else {
                            final latestStatus =
                                ref.read(postViewModelProvider()).status;
                            SnackBarHelper().openErrorSnackBar(
                              context,
                              t.post.error,
                              _getLocalizedStatus(context, latestStatus),
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
                          postState.isAnonymous
                              ? t.anonymous.share
                              : t.share.shareButton,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
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
        return t.post.errorPickImage;
      case PostStatus.error:
        return t.post.error;
      case PostStatus.photoSuccess:
        return t.post.photoSuccess;
      case PostStatus.cameraPermission:
        return t.post.cameraPermission;
      case PostStatus.albumPermission:
        return t.post.albumPermission;
      case PostStatus.success:
        return t.post.success;
      case PostStatus.loading:
        return 'Loading...';
      case PostStatus.missingPhoto:
        return t.post.missingPhoto;
      case PostStatus.missingFoodName:
        return t.post.missingFoodName;
      case PostStatus.missingRestaurant:
        return t.post.missingRestaurant;
      case PostStatus.maybeNotFood:
        return t.maybeNotFoodDialog.title;
      case PostStatus.invalidPrice:
        return t.post.priceInvalid;
      case PostStatus.initial:
        return 'Loading...';
    }
  }
}

String _maybeNotFoodDialogText(BuildContext context, int index) {
  final t = Translations.of(context);
  return t.maybeNotFoodDialog.text.replaceFirst('{index}', index.toString());
}
