import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/data/admob/admob_banner.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/component/app_profile_image.dart';
import 'package:gap/gap.dart';
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
                        AppProfileImage(imagePath: users.image, radius: 28),
                        Gap(12),
                        Text(
                          users.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: supabase.storage
                          .from('food')
                          .getPublicUrl(posts.foodImage),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(),
                        Text(
                          posts.restaurant,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          posts.foodTag,
                          style: TextStyle(fontSize: 40),
                        ),
                        Gap(50),
                        AdmobBanner(),
                        Gap(20),
                      ],
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
    );
  }
}
