import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_interstitial.dart';
import 'package:food_gram_app/core/theme/style/edit_style.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_favorite_tags_selector.dart';
import 'package:food_gram_app/ui/component/app_icon.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_post_image_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/edit/edit_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditScreen extends HookConsumerWidget {
  const EditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(editViewModelProvider().notifier);
    final state = ref.watch(editViewModelProvider());
    final loading = ref.watch(loadingProvider);
    final adInterstitial =
        useMemoized(() => ref.read(admobInterstitialNotifierProvider));
    useEffect(
      () {
        adInterstitial.createAd();
        return;
      },
      [adInterstitial],
    );
    return PopScope(
      canPop: !loading,
      child: GestureDetector(
        onTap: () => primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: !loading ? Colors.white : Colors.transparent,
            leading: !loading
                ? IconButton(
                    onPressed: () async {
                      primaryFocus?.unfocus();
                      await Future.delayed(const Duration(milliseconds: 100));
                      context.pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                    ),
                  )
                : Container(),
            actions: [
              if (!loading)
                TextButton(
                  onPressed: () {
                    ref
                        .read(editViewModelProvider().notifier)
                        .update()
                        .then((value) async {
                      if (value) {
                        await adInterstitial.showAd();
                        context.pop(true);
                      }
                    });
                  },
                  child: Text(
                    L10n.of(context).editUpdateButton,
                    style: EditStyle.editButton(loading: loading),
                  ),
                )
              else
                const SizedBox(),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      if (state.uploadImage != '')
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: FileImage(
                            File(state.uploadImage),
                          ),
                          radius: 70,
                        )
                      else if (!state.isSelectedIcon)
                        AppProfileImage(
                          imagePath: state.initialImage,
                          radius: 70,
                        )
                      else
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage:
                              AssetImage('assets/icon/icon${state.number}.png'),
                          radius: 70,
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          L10n.of(context).settingsIcon,
                          style: EditStyle.settingsIcon(),
                        ),
                      ),
                      Wrap(
                        children: [
                          ...List.generate(
                            6,
                            (index) {
                              return AppIcon(
                                onTap: () {
                                  ref
                                      .read(editViewModelProvider().notifier)
                                      .selectIcon(index + 1);
                                },
                                number: index + 1,
                              );
                            },
                          ),
                          if (state.isSubscribe)
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
                                              editViewModelProvider().notifier,
                                            )
                                            .camera();
                                      },
                                      album: () async {
                                        await ref
                                            .read(
                                              editViewModelProvider().notifier,
                                            )
                                            .album();
                                      },
                                    );
                                  },
                                );
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 8,
                                height: MediaQuery.of(context).size.width / 8,
                                child: const CircleAvatar(
                                  backgroundColor: Colors.black,
                                  child: Icon(
                                    Icons.linked_camera,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Gap(30),
                      AppNameTextField(
                        controller: controller.nameTextController,
                      ),
                      const Gap(30),
                      AppUserNameTextField(
                        controller: controller.useNameTextController,
                      ),
                      const Gap(30),
                      AppSelfIntroductionTextField(
                        controller: controller.selfIntroduceTextController,
                      ),
                      if (state.isSubscribe)
                        Column(
                          children: [
                            const Gap(16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.tag, size: 20),
                                  Text(
                                    L10n.of(context).editFavoriteTagTitle,
                                    style: EditStyle.tag(),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(10),
                            AppFavoriteTagsSelector(
                              selectedTags: state.favoriteTags,
                              onTagSelected: (tag) {
                                ref
                                    .read(
                                      editViewModelProvider().notifier,
                                    )
                                    .updateFavoriteTags(tag);
                              },
                            ),
                          ],
                        ),
                      const Gap(20),
                    ],
                  ),
                ),
              ),
              AppLoading(
                loading: loading,
                status: 'Loading...',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
