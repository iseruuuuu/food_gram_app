import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_interstitial.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/utils/helpers/share_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/share/post_share_template.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostSharePreviewView extends HookConsumerWidget {
  const PostSharePreviewView({
    required this.posts,
    required this.users,
    required this.templateId,
    required this.onBack,
    super.key,
  });

  final Posts posts;
  final Users users;
  final PostShareTemplateId templateId;
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

    final template = postShareTemplateById(templateId);
    final shareWidget = template.builder(posts, ref, t);
    final shareText = '${posts.foodName} in ${posts.restaurant}\n\n'
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
          await ref.read(firebaseAnalyticsServiceProvider).logPostShare(
                posts.id,
                shareType: hasText ? 'text_and_image' : 'image_only',
              );
          await ShareHelpers().captureAndShare(
            widget: template.builder(posts, ref, t),
            shareText: shareText,
            loading: loading,
            hasText: hasText,
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
