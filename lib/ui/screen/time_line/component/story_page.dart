import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/data/admob/admob_banner.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:heroine/heroine.dart';
import 'package:story/story_page_view.dart';

class StoryPage extends StatelessWidget {
  const StoryPage({
    required this.posts,
    required this.users,
    super.key,
  });

  final Posts posts;
  final Users users;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 50) {
            context.pop();
          }
        },
        child: Heroine(
          tag: posts.id,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: StoryPageView(
                itemBuilder: (context, pageIndex, storyIndex) {
                  return Stack(
                    children: [
                      Positioned.fill(child: Container(color: Colors.black)),
                      FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 44, left: 8),
                          child: Row(
                            children: [
                              AppProfileImage(
                                imagePath: users.image,
                                radius: 28,
                              ),
                              Gap(12),
                              FittedBox(
                                child: Text(
                                  users.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        child: CachedNetworkImage(
                          imageUrl: supabase.storage
                              .from('food')
                              .getPublicUrl(posts.foodImage),
                          fit: BoxFit.fitWidth,
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).width,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FittedBox(
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width,
                            height: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  posts.foodName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  posts.restaurant,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                AdmobBanner(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                gestureItemBuilder: (context, pageIndex, storyIndex) {
                  return Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        color: Colors.white,
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
                pageLength: 1,
                storyLength: (pageIndex) {
                  return 1;
                },
                onPageLimitReached: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
