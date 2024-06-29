import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/main.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:share_plus/share_plus.dart';

class AppShareDialog extends StatelessWidget {
  const AppShareDialog({
    required this.posts,
    required this.users,
    super.key,
  });

  final Posts posts;
  final Users users;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final l10n = L10n.of(context);
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Container(
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
                l10n.app_share_title,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Spacer(),
            Container(
              width: deviceWidth / 1.15,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: deviceWidth / 1.15,
                      height: deviceWidth / 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: supabase.storage
                              .from('food')
                              .getPublicUrl(posts.foodImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(10),
                          Text(
                            'IN ${posts.restaurant}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Gap(10),
                          Text(
                            posts.comment,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Gap(10),
                        ],
                      ),
                    ),
                  ],
                ),
                color: Colors.white,
                elevation: 0,
              ),
            ),
            Gap(40),
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
                      onPressed: () {
                        Share.share(
                          '${users.name} post in '
                          '${posts.restaurant}'
                          '\n\n${L10n.of(context).share_review_1}'
                          '\n${L10n.of(context).share_review_2}'
                          '\n\n#foodGram'
                          '\n#FoodGram',
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
                            l10n.app_share_share_store,
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
                        final availableMaps = await MapLauncher.installedMaps;
                        await availableMaps.first.showMarker(
                          coords: Coords(posts.lat, posts.lng),
                          title: posts.restaurant,
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
                            l10n.app_share_go,
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
                            l10n.app_share_close,
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
                ],
              ),
            ),
            Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
