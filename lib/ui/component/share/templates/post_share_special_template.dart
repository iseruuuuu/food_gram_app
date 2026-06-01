import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/share/post_share_branding.dart';
import 'package:food_gram_app/ui/component/share/post_share_helpers.dart';
import 'package:food_gram_app/ui/component/share/post_share_image.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostShareSpecialTemplate extends StatelessWidget {
  const PostShareSpecialTemplate({
    required this.posts,
    required this.ref,
    required this.t,
    super.key,
  });

  final Posts posts;
  final WidgetRef ref;
  final Translations t;

  static const Size size = Size(360, 640);

  @override
  Widget build(BuildContext context) {
    final imageUrl = postShareImageUrl(ref, posts);

    return ProviderScope(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PostShareImage(imageUrl: imageUrl),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                    ],
                    stops: const [0, 0.5, 1],
                  ),
                ),
              ),
              Positioned(
                top: 54,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.share.todaySpecialLabel,
                      style: TextStyle(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w300,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const Gap(16),
                    Text(
                      posts.foodName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: postShareSerifTitleStyle(
                        fontSize: 34,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      'IN ${posts.restaurant}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(14),
                    Row(
                      children: [
                        Icon(
                          Icons.local_cafe_outlined,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        const Gap(10),
                        Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        const Gap(14),
                        PostShareRating(
                          star: posts.star,
                          iconSize: 16,
                          fontSize: 15,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Positioned(
                right: 24,
                bottom: 44,
                child: PostShareBranding(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
