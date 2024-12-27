import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/core/data/admob/admob_interstitial.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_share_widget.dart';
import 'package:food_gram_app/utils/share.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

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
    final l10n = L10n.of(context);
    final adInterstitial = ref.watch(admobInterstitialProvider);
    useEffect(
      () {
        adInterstitial.createAd();
        return null;
      },
      [],
    );
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              leading: IconButton(
                onPressed: context.pop,
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              title: Text(
                l10n.appShareTitle,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            AppShareWidget(
              posts: posts,
              users: users,
            ),
            Gap(20),
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
                            final screenshotController = ScreenshotController();
                            final screenshotBytes =
                                await screenshotController.captureFromWidget(
                              AppShareWidget(
                                posts: posts,
                                users: users,
                              ),
                            );

                            /// 一時ディレクトリに保存
                            final tempDir = await getTemporaryDirectory();
                            final filePath = '${tempDir.path}/shared_image.png';
                            final file = File(filePath);
                            await file.writeAsBytes(screenshotBytes);
                            await sharePosts(
                              [XFile(file.path)],
                              '${posts.foodName} in ${posts.restaurant} '
                              '\n\n#FoodGram',
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.ios_share,
                            size: 25,
                            color: Colors.black,
                          ),
                          Gap(15),
                          Text(
                            l10n.appShareStoreButton,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(20),
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
                            final screenshotController = ScreenshotController();
                            final screenshotBytes =
                                await screenshotController.captureFromWidget(
                              AppShareWidget(
                                posts: posts,
                                users: users,
                              ),
                            );

                            /// 一時ディレクトリに保存
                            final tempDir = await getTemporaryDirectory();
                            final filePath = '${tempDir.path}/shared_image.png';
                            final file = File(filePath);
                            await file.writeAsBytes(screenshotBytes);
                            await sharePostsForInstagram([XFile(file.path)]);
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.instagram,
                            size: 25,
                            color: Colors.black,
                          ),
                          Gap(15),
                          Text(
                            l10n.appShareInstagramButton,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(20),
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
                            final availableMaps =
                                await MapLauncher.installedMaps;
                            await availableMaps.first.showMarker(
                              coords: Coords(posts.lat, posts.lng),
                              title: posts.restaurant,
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_walk,
                            size: 25,
                            color: Colors.black,
                          ),
                          Gap(15),
                          Text(
                            l10n.appShareGoButton,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: context.pop,
                      child: Row(
                        children: [
                          Icon(
                            Icons.close,
                            size: 25,
                            color: Colors.black,
                          ),
                          Gap(15),
                          Text(
                            l10n.appShareCloseButton,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
