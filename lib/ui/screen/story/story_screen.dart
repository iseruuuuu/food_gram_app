import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/admob/services/admob_banner.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/theme/style/story_style.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/profile/app_profile_image.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:story/story_page_view.dart';

class StoryScreen extends ConsumerWidget {
  const StoryScreen({
    required this.posts,
    required this.users,
    super.key,
  });

  final List<Posts> posts;
  final List<Users> users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final supabase = ref.watch(supabaseProvider);
    final l10n = L10n.of(context);
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
                            imagePath: posts[storyIndex].isAnonymous
                                ? 'assets/icon/icon1.png'
                                : users[storyIndex].image,
                            radius: 28,
                          ),
                          const Gap(12),
                          Text(
                            posts[storyIndex].isAnonymous
                                ? l10n.anonymousPoster
                                : users[storyIndex].name,
                            style: StoryStyle.name(),
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
                              style: StoryStyle.foodName(),
                            ),
                            Text(
                              posts[storyIndex].restaurant,
                              style: StoryStyle.restaurant(),
                            ),
                            const AdmobBanner(id: 'story'),
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
              storyLength: (_) => posts.length,
              onPageLimitReached: () => context.pop(),
            ),
          ),
        ),
      ),
    );
  }
}
