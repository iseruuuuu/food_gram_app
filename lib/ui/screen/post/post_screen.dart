import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/analytics_screen.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/post_draft.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/purchase/paywall_launch_guard.dart';
import 'package:food_gram_app/core/review/in_app_review_service.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/user/services/streak_service.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/theme/style/post_style.dart';
import 'package:food_gram_app/core/utils/helpers/haptic_feedback_helper.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/dialog/app_paywall_success_dialog.dart';
import 'package:food_gram_app/ui/component/dialog/app_streak_dialog.dart';
import 'package:food_gram_app/ui/component/loading/app_overlay_loading.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_post_image_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/post/components/post_draft_picker_sheet.dart';
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
    final isOptionalExpanded = useState(false);
    final isSubmittingPost = useState(false);
    final draftCount = useState(0);
    final didPromptDrafts = useRef(false);
    final isDraftPickerOpen = useRef(false);
    final paywallGuard = useMemoized(PaywallLaunchGuard.new);
    final foodTexts = useMemoized(
      () => ValueNotifier<List<String>>(
        foodTags.value
            .map((tag) => getLocalizedFoodName(tag, context))
            .toList(),
      ),
      [foodTags.value],
    );

    void applyLoadedDraft(PostDraft draft) {
      if (!context.mounted) {
        return;
      }
      final analytics = ref.read(firebaseAnalyticsServiceProvider);
      final viewModel = ref.read(postViewModelProvider().notifier);
      viewModel.markRestoredFromDraft();
      analytics.logScreen(AnalyticsScreen.draft);
      analytics.logEventUnawaited(name: AnalyticsEvent.draftOpen);
      viewModel.applyDraft(
        draft,
        applyRestaurant: restaurant == null,
      );
      foodTags.value = List<String>.from(draft.foodTags);
      viewModel.captureCompositionBaseline(foodTags: foodTags.value);
      isOptionalExpanded.value =
          draft.foodName.trim().isNotEmpty ||
          draft.foodTags.isNotEmpty ||
          draft.comment.trim().isNotEmpty ||
          draft.priceInput.trim().isNotEmpty ||
          draft.star > 0;
      SnackBarHelper().openSuccessSnackBar(
        context,
        t.post.title,
        t.post.draftRestored,
      );
    }

    Future<List<PostDraft>> reloadDrafts() async {
      final drafts = await ref
          .read(postViewModelProvider().notifier)
          .loadSavedDrafts();
      if (context.mounted) {
        draftCount.value = drafts.length;
      }
      return drafts;
    }

    Future<void> finishDraftSave(PostDraftSaveResult result) async {
      if (!context.mounted) {
        return;
      }
      if (result != PostDraftSaveResult.empty &&
          result != PostDraftSaveResult.subscriptionRequired) {
        ref
            .read(postViewModelProvider().notifier)
            .captureCompositionBaseline(foodTags: foodTags.value);
      }
      switch (result) {
        case PostDraftSaveResult.empty:
          SnackBarHelper().openSimpleSnackBar(
            context,
            t.post.draftNothingToSave,
          );
        case PostDraftSaveResult.unchanged:
        case PostDraftSaveResult.subscriptionRequired:
          break;
        case PostDraftSaveResult.saved:
        case PostDraftSaveResult.created:
        case PostDraftSaveResult.trimmed:
          await reloadDrafts();
          if (!context.mounted) {
            return;
          }
          final message = switch (result) {
            PostDraftSaveResult.trimmed => t.post.draftSavedTrimmed,
            PostDraftSaveResult.created => t.post.draftSavedAsNew,
            _ => t.post.draftSaved,
          };
          SnackBarHelper().openSuccessSnackBar(
            context,
            t.post.saveDraft,
            message,
          );
      }
    }

    Future<bool> confirmDiscard({
      required BuildContext dialogContext,
      required String title,
      required String message,
      required String action,
    }) async {
      final accepted = await showDialog<bool>(
        context: dialogContext,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(t.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(action),
              ),
            ],
          );
        },
      );
      return accepted == true && dialogContext.mounted;
    }

    Future<void> openDraftPicker() async {
      if (isDraftPickerOpen.value || !context.mounted) {
        return;
      }
      isDraftPickerOpen.value = true;
      try {
        final drafts = await reloadDrafts();
        if (!context.mounted || drafts.isEmpty) {
          return;
        }
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {
            return PostDraftPickerSheet(
              drafts: drafts,
              onSelect: (draft) async {
                final notifier = ref.read(postViewModelProvider().notifier);
                final discard = notifier.hasUnsavedDraftEdits(
                  foodTags: foodTags.value,
                );
                if (discard) {
                  final accepted = await confirmDiscard(
                    dialogContext: sheetContext,
                    title: t.post.replaceDraftConfirmTitle,
                    message: t.post.replaceDraftConfirmMessage,
                    action: t.post.replaceDraftConfirmAction,
                  );
                  if (!accepted || !sheetContext.mounted) {
                    return;
                  }
                }
                if (!sheetContext.mounted) {
                  return;
                }
                Navigator.of(sheetContext).pop();
                applyLoadedDraft(draft);
              },
              onDelete: (ids) async {
                await ref
                    .read(postViewModelProvider().notifier)
                    .deleteDrafts(ids);
                final latest = await reloadDrafts();
                if (sheetContext.mounted) {
                  SnackBarHelper().openSuccessSnackBar(
                    sheetContext,
                    t.post.draftsTitle,
                    t.post.draftsDeleted,
                  );
                }
                return latest;
              },
              onStartNew: () async {
                final notifier = ref.read(postViewModelProvider().notifier);
                final discard = notifier.hasContentToDiscard(
                  foodTags: foodTags.value,
                  keepRestaurant: restaurant != null,
                );
                if (discard) {
                  final accepted = await confirmDiscard(
                    dialogContext: sheetContext,
                    title: t.post.newDraftConfirmTitle,
                    message: t.post.newDraftConfirmMessage,
                    action: t.post.newDraft,
                  );
                  if (!accepted || !sheetContext.mounted) {
                    return;
                  }
                }
                Navigator.of(sheetContext).pop();
                notifier.startNewDraft(keepRestaurant: restaurant != null);
                foodTags.value = [];
                notifier.captureCompositionBaseline(foodTags: foodTags.value);
                isOptionalExpanded.value = false;
              },
            );
          },
        );
      } finally {
        isDraftPickerOpen.value = false;
      }
    }

    useEffect(
      () {
        final analytics = ref.read(firebaseAnalyticsServiceProvider);
        // ScreenView(Post) は GoRouter Observer が送信。Draft のみ手動。
        unawaited(analytics.logPostStart(source: routerPath));
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (didPromptDrafts.value) {
            return;
          }
          didPromptDrafts.value = true;
          if (restaurant != null) {
            ref
                .read(postViewModelProvider().notifier)
                .loadRestaurant(restaurant);
          }
          ref
              .read(postViewModelProvider().notifier)
              .captureCompositionBaseline(foodTags: foodTags.value);
          final drafts = await reloadDrafts();
          if (!context.mounted || drafts.isEmpty) {
            return;
          }
          if (drafts.length == 1) {
            applyLoadedDraft(drafts.single);
            return;
          }
          await openDraftPicker();
        });
        return null;
      },
      [restaurant],
    );
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
                            accent: requiredAccent,
                          ),
                          const Gap(14),
                          PostPhotoArea(
                            foodImages: postState.foodImages,
                            onAddPhoto: openImagePicker,
                            onRemoveImage: viewModel.removeImage,
                            accent: requiredAccent,
                            borderColor: PostStyle.requiredBorder(context),
                          ),
                          const Gap(12),
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
                    PostCollapsibleOptionalSection(
                      isExpanded: isOptionalExpanded.value,
                      onToggle: () {
                        isOptionalExpanded.value = !isOptionalExpanded.value;
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PostFieldLabel(
                            icon: Icons.fastfood_outlined,
                            label: t.post.foodNameRequired,
                            accent: optionalAccent,
                          ),
                          const Gap(8),
                          PostTextInputField(
                            controller: viewModel.foodController,
                            hint: t.post.foodNamePlaceholder,
                          ),
                          const Gap(16),
                          PostFoodTagField(
                            foodTags: foodTags.value,
                            foodTexts: foodTexts,
                            onTagSelected: (tags) {
                              foodTags.value = tags;
                              if (tags.isNotEmpty) {
                                ref
                                    .read(firebaseAnalyticsServiceProvider)
                                    .logEventUnawaited(
                                      name: AnalyticsEvent.postTagSelected,
                                      parameters: {
                                        AnalyticsParam.tag: tags.join(','),
                                      },
                                    );
                              }
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
                        border: Border.all(
                          color: PostStyle.fieldBorderColor(context),
                        ),
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
                                  t.private.post,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  t.private.postDescription,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: postState.isAnonymous,
                            activeThumbColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            activeTrackColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.3),
                            inactiveTrackColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]
                                : Colors.grey[300],
                            inactiveThumbColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.white,
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
                    if (draftCount.value > 0) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: TextButton(
                          onPressed: () {
                            primaryFocus?.unfocus();
                            openDraftPicker();
                          },
                          child: Text(
                            t.post.openDrafts.replaceAll(
                              '{count}',
                              '${draftCount.value}',
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                        ),
                      ),
                      const Gap(4),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () async {
                          primaryFocus?.unfocus();
                          final notifier = ref.read(
                            postViewModelProvider().notifier,
                          );
                          final result = await notifier.saveDraft(
                            foodTags: foodTags.value,
                          );
                          if (!context.mounted) {
                            return;
                          }
                          if (result ==
                              PostDraftSaveResult.subscriptionRequired) {
                            ref
                                .read(firebaseAnalyticsServiceProvider)
                                .logPremiumFeatureTap(
                                  AnalyticsEvent.premiumDraftLimitTap,
                                );
                            final purchased = await paywallGuard.present(
                              context: context,
                              ref: ref,
                              source: 'post_draft_limit',
                            );
                            if (!purchased || !context.mounted) {
                              return;
                            }
                            await showPaywallSuccessDialog(context: context);
                            if (!context.mounted) {
                              return;
                            }
                            final saved = await notifier.saveDraft(
                              foodTags: foodTags.value,
                            );
                            await finishDraftSave(saved);
                            return;
                          }
                          await finishDraftSave(result);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
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
                        onPressed: isSubmittingPost.value
                            ? null
                            : () async {
                                HapticFeedbackHelper.medium();
                                isSubmittingPost.value = true;
                                final foodTagString = foodTags.value.isEmpty
                                    ? ''
                                    : foodTags.value.join(',');
                                final comment = ref
                                    .read(postViewModelProvider().notifier)
                                    .commentController
                                    .text;
                                if (comment.trim().isNotEmpty) {
                                  ref
                                      .read(firebaseAnalyticsServiceProvider)
                                      .logEventUnawaited(
                                        name: AnalyticsEvent.postCommentInput,
                                      );
                                }
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
                                  final postCount =
                                      (ref
                                              .read(myPostStreamProvider)
                                              .value
                                              ?.length ??
                                          0) +
                                      1;
                                  unawaited(
                                    ref
                                        .read(firebaseAnalyticsServiceProvider)
                                        .logPostCountMilestones(postCount),
                                  );
                                  // ストリークを更新
                                  final streakService = ref.read(
                                    streakServiceProvider.notifier,
                                  );
                                  final streakResult = await streakService
                                      .updateStreak();
                                  if (!context.mounted) {
                                    return;
                                  }
                                  // ストリークが更新された場合のみダイアログを表示
                                  if (streakResult.isUpdated) {
                                    final analytics = ref.read(
                                      firebaseAnalyticsServiceProvider,
                                    );
                                    analytics.logEventUnawaited(
                                      name: AnalyticsEvent.streakView,
                                      parameters: {
                                        AnalyticsParam.streakWeeks:
                                            streakResult.newStreakWeeks,
                                      },
                                    );
                                    if (streakResult.newStreakWeeks > 1) {
                                      analytics.logEventUnawaited(
                                        name: AnalyticsEvent.streakContinue,
                                        parameters: {
                                          AnalyticsParam.streakWeeks:
                                              streakResult.newStreakWeeks,
                                        },
                                      );
                                    }
                                    // ダイアログを表示（初回投稿かどうかを判定）
                                    final isFirstTime =
                                        streakResult.newStreakWeeks == 1;
                                    // ストリークの節目（3週、5週、10週）を判定
                                    final milestoneWeeks = [3, 5, 10];
                                    final isMilestone = milestoneWeeks.contains(
                                      streakResult.newStreakWeeks,
                                    );

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
                                      final reviewService =
                                          InAppReviewService();
                                      await reviewService.requestReview();
                                    }
                                  }
                                  if (context.mounted) {
                                    context.pop(true);
                                  }
                                } else {
                                  isSubmittingPost.value = false;
                                  final latestStatus = ref
                                      .read(postViewModelProvider())
                                      .status;
                                  final isNetworkError =
                                      latestStatus ==
                                      PostStatus.networkError.name;
                                  SnackBarHelper().openErrorSnackBar(
                                    context,
                                    isNetworkError
                                        ? t.error.title
                                        : t.post.error,
                                    isNetworkError
                                        ? t.error.description2
                                        : _getLocalizedStatus(
                                            context,
                                            latestStatus,
                                          ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
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
                              ? t.private.share
                              : t.share.shareButton,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
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
      case PostStatus.networkError:
        return t.error.description2;
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
      case PostStatus.invalidPrice:
        return t.post.priceInvalid;
      case PostStatus.initial:
        return 'Loading...';
    }
  }
}
