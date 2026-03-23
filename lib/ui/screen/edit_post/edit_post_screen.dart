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
import 'package:food_gram_app/core/theme/style/post_style.dart';
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
    // 複数画像編集で2枚目以降も開くため、常に有効な context（build の context）を渡す
    final navigatorContext = context;
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
    final priceCurrency =
        ref.watch(editPostViewModelProvider().select((s) => s.priceCurrency));
    final viewModel = ref.watch(editPostViewModelProvider().notifier);
    final foodTags = useState<List<String>>(
      posts.foodTag.isNotEmpty ? posts.foodTag.split(',') : [],
    );
    // 削除タップ時にそのスロットを即プレースホルダー表示にするため
    final removingPaths = ref.watch(editPostRemovingPathsProvider);
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
    // リストから消えたパスを removingPaths から削除（ビルド外で更新するため遅延）
    useEffect(
      () {
        final current = ref.read(editPostRemovingPathsProvider);
        final next = current
            .where(
              (p) => existingImagePaths.contains(p) || foodImages.contains(p),
            )
            .toSet();
        if (next.length != current.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(editPostRemovingPathsProvider.notifier).state = next;
          });
        }
        return null;
      },
      [existingImagePaths, foodImages],
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
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: loading ? Colors.transparent : null,
          title: Text(
            t.edit.editTitle,
            style: EditPostStyle.editTitle(context),
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
                    const Gap(12),
                    Column(
                      children: [
                        // 既存の画像（サーバーから読み込んだもの）
                        if (existingImagePaths.isNotEmpty)
                          SizedBox(
                            key: ValueKey(
                              'existing_${existingImagePaths.join('|')}',
                            ),
                            height: deviceWidth / 1.7,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: existingImagePaths.length,
                              itemBuilder: (context, index) {
                                final imagePath = existingImagePaths[index];
                                final existingImageUrl = supabase.storage
                                    .from('food')
                                    .getPublicUrl(imagePath);
                                final isRemoving =
                                    removingPaths.contains(imagePath);
                                return Padding(
                                  key: ValueKey(imagePath),
                                  padding: EdgeInsets.only(
                                    right: index < existingImagePaths.length - 1
                                        ? 12
                                        : 0,
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: isRemoving
                                              ? Colors.grey.shade300
                                              : Colors.white,
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
                                          child: isRemoving
                                              ? Center(
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    size: 48,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                )
                                              : CachedNetworkImage(
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
                                                  editPostRemovingPathsProvider
                                                      .notifier,
                                                )
                                                .state = {
                                              ...ref.read(
                                                editPostRemovingPathsProvider,
                                              ),
                                              imagePath,
                                            };
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
                            key: ValueKey('food_${foodImages.join('|')}'),
                            height: deviceWidth / 1.7,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: foodImages.length,
                              itemBuilder: (context, index) {
                                final imagePath = foodImages[index];
                                final isRemoving =
                                    removingPaths.contains(imagePath);
                                return Padding(
                                  key: ValueKey(imagePath),
                                  padding: EdgeInsets.only(
                                    right:
                                        index < foodImages.length - 1 ? 12 : 0,
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: isRemoving
                                              ? Colors.grey.shade300
                                              : Colors.white,
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
                                          child: isRemoving
                                              ? Center(
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    size: 48,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                )
                                              : Image.file(
                                                  File(imagePath),
                                                  fit: BoxFit.cover,
                                                  cacheWidth: previewWidth,
                                                  cacheHeight: previewHeight,
                                                  filterQuality:
                                                      FilterQuality.high,
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
                                                  editPostRemovingPathsProvider
                                                      .notifier,
                                                )
                                                .state = {
                                              ...ref.read(
                                                editPostRemovingPathsProvider,
                                              ),
                                              imagePath,
                                            };
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
                                                editPostViewModelProvider()
                                                    .notifier,
                                              )
                                              .camera(navigatorContext);
                                        },
                                        album: () async {
                                          await ref
                                              .read(
                                                editPostViewModelProvider()
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
                                  child: foodImageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: foodImageUrl,
                                            fit: BoxFit.cover,
                                            memCacheWidth: previewWidth,
                                            memCacheHeight: previewHeight,
                                          ),
                                        )
                                      : Icon(
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
                    AppFoodTextField(controller: viewModel.foodController),
                    const Gap(12),
                    Builder(
                      builder: (context) {
                        final scheme = Theme.of(context).colorScheme;
                        return GestureDetector(
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
                                              restaurantName,
                                              overflow: TextOverflow.ellipsis,
                                              style: EditPostStyle.restaurant(
                                                context,
                                              ),
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
                      controller: viewModel.priceController,
                      currencyCode: priceCurrency,
                      onCurrencyChanged: (code) {
                        ref
                            .read(editPostViewModelProvider().notifier)
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
                          RatingBar.builder(
                            initialRating: star,
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
                                  .read(editPostViewModelProvider().notifier)
                                  .setStar(rating);
                            },
                          ),
                          const Spacer(),
                          Text(
                            star.toStringAsFixed(1),
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
                      controller: viewModel.commentController,
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
                        value: isAnonymous,
                        activeThumbColor: Theme.of(context).colorScheme.primary,
                        activeTrackColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3),
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
      case EditStatus.invalidPrice:
        return Translations.of(context).post.priceInvalid;
    }
  }
}

String _maybeNotFoodDialogText(BuildContext context, int index) {
  final t = Translations.of(context);
  return t.maybeNotFoodDialog.text.replaceFirst('{index}', index.toString());
}
