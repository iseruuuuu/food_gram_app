import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/theme/style/edit_post_style.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_tag.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
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
    final state = ref.watch(editPostViewModelProvider());
    final viewModel = ref.watch(editPostViewModelProvider().notifier);
    final countryTag = useState(posts.restaurantTag);
    final countryText = useMemoized(
      () => ValueNotifier(
        countryTag.value.isNotEmpty
            ? getLocalizedCountryName(countryTag.value, context)
            : '',
      ),
      [countryTag.value],
    );
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
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black87),
                          ),
                          width: deviceWidth,
                          height: deviceWidth / 1.7,
                          child: state.foodImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(state.foodImage),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: foodImageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
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
                                          state.restaurant,
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
                    const Gap(12),
                    Text(
                      l10n.postCategoryTitle,
                      style: EditPostStyle.category(),
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
                        activeColor: Colors.blue[600],
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
                      // List<String>をカンマ区切りのStringに変換
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
                          l10n.postError,
                          _getLocalizedStatus(context, state.status),
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
                          ? l10n.anonymousUpdate
                          : l10n.editUpdateButton,
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
