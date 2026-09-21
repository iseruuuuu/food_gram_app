import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_interstitial.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/utils/helpers/share_helper.dart';
import 'package:food_gram_app/core/utils/restaurant/restaurant_display_name.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/loading/app_overlay_loading.dart';
import 'package:food_gram_app/ui/component/share/post_share_type.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppShareDialog extends HookConsumerWidget {
  const AppShareDialog({
    required this.posts,
    required this.users,
    super.key,
  });

  final Posts posts;
  final Users users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTemplate = useState<PostShare?>(null);

    if (selectedTemplate.value == null) {
      return _PostShareSelection(
        posts: posts,
        onTemplateSelected: (template) {
          selectedTemplate.value = template;
        },
        onClose: () => Navigator.of(context).pop(),
      );
    }

    return _PostSharePreview(
      posts: posts,
      template: selectedTemplate.value!,
      onBack: () {
        selectedTemplate.value = null;
      },
    );
  }
}

class _PostShareSelection extends HookConsumerWidget {
  const _PostShareSelection({
    required this.posts,
    required this.onTemplateSelected,
    required this.onClose,
  });

  final Posts posts;
  final ValueChanged<PostShare> onTemplateSelected;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: onClose,
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onSurface,
          ),
        ),
        title: Text(
          t.share.chooseTemplate,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: PostShare.values.length,
        itemBuilder: (context, index) {
          final template = PostShare.values[index];
          return _TemplateGridItem(
            template: template,
            posts: posts,
            ref: ref,
            onTap: () => onTemplateSelected(template),
          );
        },
      ),
    );
  }
}

class _TemplateGridItem extends StatelessWidget {
  const _TemplateGridItem({
    required this.template,
    required this.posts,
    required this.ref,
    required this.onTap,
  });

  final PostShare template;
  final Posts posts;
  final WidgetRef ref;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final aspectRatio = template.size.width / template.size.height;

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: FittedBox(
                  child: template.toWidget(posts: posts, ref: ref),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostSharePreview extends HookConsumerWidget {
  const _PostSharePreview({
    required this.posts,
    required this.template,
    required this.onBack,
  });

  final Posts posts;
  final PostShare template;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final loading = useState(false);
    final adInterstitial =
        useMemoized(() => ref.read(admobInterstitialNotifierProvider));
    useEffect(
      () {
        adInterstitial.createAd();
        return;
      },
      [adInterstitial],
    );

    final shareWidget = template.toWidget(posts: posts, ref: ref);
    final supabase = ref.watch(supabaseProvider);
    final imageUrl =
        supabase.storage.from('food').getPublicUrl(posts.firstFoodImage);
    final shareHeadline = posts.hasFoodName && posts.hasRestaurant
        ? '${posts.foodName} in ${posts.localizedRestaurant(t)}'
        : posts.localizedDisplayTitle(t);
    final shareText = '$shareHeadline\n\n'
        '${t.share.inviteMessage}\n'
        '#FoodGram';
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayFg = isDark ? colorScheme.onSurface : Colors.white;
    final overlayBtnBg = colorScheme.surface;
    final overlayBtnFg = colorScheme.onSurface;
    final aspectRatio = template.size.width / template.size.height;

    Future<void> share({required bool hasText}) async {
      await adInterstitial.showAd(
        onAdClosed: () async {
          if (!context.mounted) {
            return;
          }
          // 広告閉鎖直後は iOS でシェアシートが出せないことがあるため少し待つ
          await Future<void>.delayed(const Duration(milliseconds: 350));
          if (!context.mounted) {
            return;
          }
          unawaited(
            ref.read(firebaseAnalyticsServiceProvider).logPostShare(
                  posts.id,
                  shareType: hasText ? 'text_and_image' : 'image_only',
                ),
          );
          ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
            name: hasText
                ? AnalyticsEvent.postShareLink
                : AnalyticsEvent.postShareImage,
            parameters: {AnalyticsParam.postId: posts.id},
          );
          await ShareHelpers().captureAndShare(
            context: context,
            widget: shareWidget,
            shareText: shareText,
            loading: loading,
            hasText: hasText,
            targetSize: template.size,
            pixelRatio: 3,
            precacheImageUrl: imageUrl,
            errorMessage: t.error.message,
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.92),
      body: Stack(
        children: [
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  onPressed: onBack,
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: overlayFg,
                  ),
                ),
                title: Text(
                  t.share.previewTitle,
                  style: TextStyle(
                    color: overlayFg,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: FittedBox(
                        child: shareWidget,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: overlayBtnBg,
                          foregroundColor: overlayBtnFg,
                        ),
                        onPressed: () => share(hasText: true),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.ios_share,
                              size: 22,
                              color: overlayBtnFg,
                            ),
                            const Gap(12),
                            Text(
                              t.share.textAndImage,
                              style: TextStyle(
                                fontSize: 16,
                                color: overlayBtnFg,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: overlayBtnBg,
                          foregroundColor: overlayBtnFg,
                        ),
                        onPressed: () => share(hasText: false),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_outlined,
                              size: 22,
                              color: overlayBtnFg,
                            ),
                            const Gap(12),
                            Text(
                              t.share.imageOnly,
                              style: TextStyle(
                                fontSize: 16,
                                color: overlayBtnFg,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppProcessLoading(loading: loading.value, status: 'Loading...'),
        ],
      ),
    );
  }
}
