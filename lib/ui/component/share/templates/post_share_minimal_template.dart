import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/ui/component/share/post_share_branding.dart';
import 'package:food_gram_app/ui/component/share/post_share_helpers.dart';
import 'package:food_gram_app/ui/component/share/post_share_image.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostShareMinimalTemplate extends StatelessWidget {
  const PostShareMinimalTemplate({
    required this.posts,
    required this.ref,
    super.key,
  });

  final Posts posts;
  final WidgetRef ref;

  static const Size size = Size(360, 640);
  static const _backgroundColor = Color(0xFFF8F4EC);
  static const _textColor = Color(0xFF2C2418);

  @override
  Widget build(BuildContext context) {
    final imageUrl = postShareImageUrl(ref, posts);

    return ProviderScope(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE8E0D4),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Assets.icon.icon3.image(
                      width: 28,
                      height: 28,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.brush_outlined,
                    size: 18,
                    color: _textColor.withValues(alpha: 0.45),
                  ),
                  const Gap(12),
                  Assets.icon.icon3.image(
                    width: 22,
                    height: 22,
                  ),
                ],
              ),
              const Gap(14),
              Text(
                posts.foodName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: postShareSerifTitleStyle(
                  fontSize: 28,
                  color: _textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(4),
              Text(
                'IN ${posts.restaurant}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: _textColor.withValues(alpha: 0.75),
                ),
              ),
              const Gap(8),
              PostShareRating(
                star: posts.star,
                color: _textColor,
                iconSize: 16,
                fontSize: 14,
              ),
              const Gap(14),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: PostShareImage(imageUrl: imageUrl),
                ),
              ),
              const Gap(12),
              Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 22,
                    color: _textColor.withValues(alpha: 0.7),
                  ),
                  const Gap(16),
                  Icon(
                    Icons.ios_share,
                    size: 22,
                    color: _textColor.withValues(alpha: 0.7),
                  ),
                  const Spacer(),
                  const PostShareBranding(
                    lightBackground: true,
                    showIcon: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
