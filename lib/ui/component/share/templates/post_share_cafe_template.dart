import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/share/post_share_branding.dart';
import 'package:food_gram_app/ui/component/share/post_share_helpers.dart';
import 'package:food_gram_app/ui/component/share/post_share_image.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostShareCafeTemplate extends StatelessWidget {
  const PostShareCafeTemplate({
    required this.posts,
    required this.ref,
    required this.t,
    super.key,
  });

  final Posts posts;
  final WidgetRef ref;
  final Translations t;

  static const Size size = Size(360, 520);
  static const _accentColor = Color(0xFFD4AF6A);

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
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
                ),
              ),
              Positioned(
                top: 28,
                left: 24,
                right: 24,
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 1,
                      color: _accentColor,
                    ),
                    const Gap(8),
                    Text(
                      t.share.cafeTimeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const Gap(8),
                    Container(
                      width: 48,
                      height: 1,
                      color: _accentColor,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 96,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      posts.foodName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: postShareSerifTitleStyle(
                        fontSize: 34,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'IN ${posts.restaurant}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(10),
                    PostShareRating(star: posts.star),
                  ],
                ),
              ),
              const Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Spacer(),
                    Gap(12),
                    PostShareBranding(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
