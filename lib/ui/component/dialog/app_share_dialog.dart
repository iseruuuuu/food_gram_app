import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_interstitial.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/utils/helpers/share_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/app_share_widget.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
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
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  leading: IconButton(
                    onPressed: context.pop,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    t.app.shareTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                AppShareWidget(posts: posts, ref: ref),
                const Gap(20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await adInterstitial.showAd(
                              onAdClosed: () async {
                                await ShareHelpers().captureAndShare(
                                  widget: AppShareWidget(
                                    posts: posts,
                                    ref: ref,
                                  ),
                                  shareText: '${posts.foodName} '
                                      'in ${posts.restaurant}\n\n '
                                      '${t.share.inviteMessage}\n'
                                      '#FoodGram',
                                  loading: loading,
                                  hasText: true,
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.ios_share,
                                size: 25,
                                color: Colors.black,
                              ),
                              const Gap(15),
                              Text(
                                t.share.textAndImage,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(20),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await adInterstitial.showAd(
                              onAdClosed: () async {
                                await ShareHelpers().captureAndShare(
                                  widget: AppShareWidget(
                                    posts: posts,
                                    ref: ref,
                                  ),
                                  loading: loading,
                                  hasText: false,
                                );
                              },
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.photo_outlined,
                                size: 25,
                                color: Colors.black,
                              ),
                              const Gap(15),
                              Text(
                                t.share.imageOnly,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppProcessLoading(loading: loading.value, status: 'Loading...'),
        ],
      ),
    );
  }
}
