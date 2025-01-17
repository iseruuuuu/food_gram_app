import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/data/admob/admob_banner.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:story/story_page_view.dart';

class StoryPage extends StatelessWidget {
  const StoryPage({
    required this.posts,
    required this.users,
    super.key,
  });

  final List<Posts> posts;
  final List<Users> users;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 50) {
            context.pop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: StoryPageView(
              itemBuilder: (context, pageIndex, storyIndex) {
                return Stack(
                  children: [
                    Positioned.fill(child: Container(color: Colors.black)),
                    Padding(
                      padding: const EdgeInsets.only(top: 44, left: 8),
                      child: Row(
                        children: [
                          AppProfileImage(
                            imagePath: users[storyIndex].image,
                            radius: 28,
                          ),
                          const Gap(12),
                          Text(
                            users[storyIndex].name,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: CachedNetworkImage(
                        imageUrl: supabase.storage
                            .from('food')
                            .getPublicUrl(posts[storyIndex].foodImage),
                        fit: BoxFit.cover,
                        width: screenWidth,
                        height: screenWidth,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: screenWidth,
                        padding: const EdgeInsets.all(16),
                        color: Colors.black.withValues(alpha: 0.6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              posts[storyIndex].foodName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              posts[storyIndex].restaurant,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const AdmobBanner(),
                          ],
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
                    padding: const EdgeInsets.only(top: 32, right: 8),
                    child: IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                  ),
                );
              },
              pageLength: 1,
              storyLength: (_) => 4,
              onPageLimitReached: () => context.pop(),
            ),
          ),
        ),
      ),
    );
  }
}
