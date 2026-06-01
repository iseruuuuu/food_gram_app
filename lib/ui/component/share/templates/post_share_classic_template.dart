import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/ui/component/share/post_share_branding.dart';
import 'package:food_gram_app/ui/component/share/post_share_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostShareClassicTemplate extends StatelessWidget {
  const PostShareClassicTemplate({
    required this.posts,
    required this.ref,
    super.key,
  });

  final Posts posts;
  final WidgetRef ref;

  static const Size size = Size(350, 420);

  @override
  Widget build(BuildContext context) {
    final supabase = ref.watch(supabaseProvider);
    final imageUrl =
        supabase.storage.from('food').getPublicUrl(posts.firstFoodImage);

    return ProviderScope(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                SizedBox.expand(
                  child: PostShareImage(imageUrl: imageUrl),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          posts.foodName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            'IN ${posts.restaurant}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            const Spacer(),
                            const PostShareBranding(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
