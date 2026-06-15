import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/review/in_app_review_service.dart';
import 'package:food_gram_app/core/supabase/user/services/streak_service.dart';
import 'package:food_gram_app/core/theme/style/post_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/dialog/app_maybe_not_food_dialog.dart';
import 'package:food_gram_app/ui/component/dialog/app_photo_nearby_restaurant_dialog.dart';
import 'package:food_gram_app/ui/component/dialog/app_streak_dialog.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_post_image_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/post/components/post_form_widgets.dart';
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
    final nearbyTrigger = ref.watch(
      postViewModelProvider().select(
        (s) => (
          photoLat: s.photoLat,
          photoLng: s.photoLng,
          dismissed: s.nearbySuggestionDismissed,
          restaurant: s.restaurant,
          hasImages: s.foodImages.isNotEmpty,
          status: s.status,
        ),
      ),
    );
    final lastShownNearbyGps = useRef<String?>(null);
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
        ref.read(firebaseAnalyticsServiceProvider).logPostStart(
              source: routerPath,
            );
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
            ref.read(postViewModelProvider().notifier).markRestoredFromDraft();
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
    useEffect(
      () {
        final lat = nearbyTrigger.photoLat;
        final lng = nearbyTrigger.photoLng;
        if (!nearbyTrigger.hasImages || lat == null || lng == null) {
          lastShownNearbyGps.value = null;
          return null;
        }
        if (nearbyTrigger.dismissed) {
          return null;
        }
        if (nearbyTrigger.restaurant != PostViewModel.defaultRestaurantText) {
          return null;
        }
        if (nearbyTrigger.status == PostStatus.maybeNotFood.name) {
          return null;
        }

        final gpsKey = '${lat}_$lng';
        if (lastShownNearbyGps.value == gpsKey) {
          return null;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) {
            return;
          }
          lastShownNearbyGps.value = gpsKey;
          await showPhotoNearbyRestaurantDialog(
            context: context,
            ref: ref,
            routerPath: routerPath,
            latitude: lat,
            longitude: lng,
          );
        });
        return null;
      },
      [
        nearbyTrigger.photoLat,
        nearbyTrigger.photoLng,
        nearbyTrigger.dismissed,
        nearbyTrigger.restaurant,
        nearbyTrigger.hasImages,
        nearbyTrigger.status,
      ],
    );
    // プレビューサイズに合わせて縮小デコード（物理解像度で指定）
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final previewWidth = (deviceWidth * 0.85 * devicePixelRatio).round();
    final previewHeight = (deviceWidth / 1.7 * devicePixelRatio).round();
    final viewModel = ref.read(postViewModelProvider().notifier);
    const requiredAccent = PostStyle.requiredAccent;
    const optionalAccent = PostStyle.optionalAccent;

    Future<void> openImagePicker() async {
      primaryFocus?.unfocus();
      await showModalBottomSheet<void>(
        context: navigatorContext,
        builder: (_) {
          return AppPostImageModalSheet(
            camera: () async {
              await viewModel.camera(navigatorContext);
            },
            album: () async {
              await viewModel.album(navigatorContext);
            },
          );
        },
      );
    }

    Future<void> openRestaurantSearch() async {
      primaryFocus?.unfocus();
      final result = await context.pushNamed(routerPath);
      if (result != null) {
        viewModel.getPlace(result as Restaurant);
      }
    }

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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostSectionCard(
                      accent: requiredAccent,
                      backgroundColor: PostStyle.requiredBg(context),
                      borderColor: PostStyle.requiredBorder(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PostSectionHeader(
                            title: t.post.requiredSectionTitle,
                            badge: t.post.requiredBadge,
                            subtitle: t.post.requiredSectionSubtitle,
                            accent: requiredAccent,
                          ),
                          const Gap(14),
                          PostPhotoArea(
                            foodImages: postState.foodImages,
                            deviceWidth: deviceWidth,
                            previewWidth: previewWidth,
                            previewHeight: previewHeight,
                            onAddPhoto: openImagePicker,
                            onRemoveImage: viewModel.removeImage,
                            accent: requiredAccent,
                            borderColor: PostStyle.requiredBorder(context),
                          ),
                          const Gap(16),
                          PostFieldLabel(
                            icon: Icons.fastfood_outlined,
                            label: t.post.foodNameRequired,
                            accent: requiredAccent,
                          ),
                          const Gap(8),
                          PostTextInputField(
                            controller: viewModel.foodController,
                            hint: t.post.foodNamePlaceholder,
                          ),
                          const Gap(16),
                          PostFieldLabel(
                            icon: Icons.place_outlined,
                            label: t.post.restaurantNameRequired,
                            accent: requiredAccent,
                          ),
                          const Gap(8),
                          PostRestaurantField(
                            restaurant: postState.restaurant,
                            defaultRestaurantText:
                                PostViewModel.defaultRestaurantText,
                            onTap: openRestaurantSearch,
                            accent: requiredAccent,
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    PostSectionCard(
                      accent: optionalAccent,
                      backgroundColor: PostStyle.optionalBg(context),
                      borderColor: PostStyle.optionalBorder(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PostSectionHeader(
                            title: t.post.optionalSectionTitle,
                            badge: t.post.optionalBadge,
                            subtitle: t.post.optionalSectionSubtitle,
                            accent: optionalAccent,
                          ),
                          const Gap(14),
                          PostFoodTagField(
                            foodTags: foodTags.value,
                            foodTexts: foodTexts,
                            onTagSelected: (tags) {
                              foodTags.value = tags;
                            },
                            accent: optionalAccent,
                          ),
                          const Gap(16),
                          PostCommentField(
                            controller: viewModel.commentController,
                            accent: optionalAccent,
                          ),
                          const Gap(16),
                          PostPriceAndRatingRow(
                            priceController: viewModel.priceController,
                            currencyCode: postState.priceCurrency,
                            onCurrencyChanged: viewModel.setPriceCurrency,
                            star: postState.star,
                            onRatingUpdate: viewModel.setStar,
                            accent: optionalAccent,
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: PostStyle.fieldBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility_off_outlined,
                            size: 24,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.anonymous.post,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  t.anonymous.postDescription,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: postState.isAnonymous,
                            activeThumbColor:
                                Theme.of(context).colorScheme.primary,
                            activeTrackColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.3),
                            inactiveTrackColor: Colors.grey[300],
                            inactiveThumbColor: Colors.white,
                            onChanged: (value) {
                              viewModel.setAnonymous(value: value);
                            },
                          ),
                        ],
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
