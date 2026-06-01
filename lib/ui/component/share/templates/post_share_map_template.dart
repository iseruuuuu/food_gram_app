import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/share/post_share_branding.dart';
import 'package:food_gram_app/ui/component/share/post_share_helpers.dart';
import 'package:food_gram_app/ui/component/share/post_share_image.dart';
import 'package:food_gram_app/ui/component/share/post_share_map_placeholder.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostShareMapTemplate extends StatelessWidget {
  const PostShareMapTemplate({
    required this.posts,
    required this.ref,
    required this.t,
    super.key,
  });

  final Posts posts;
  final WidgetRef ref;
  final Translations t;

  static const Size size = Size(360, 640);
  static const _backgroundColor = Color(0xFFF5F0E8);
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
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.share.todayShopLabel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          'IN ${posts.restaurant}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: _textColor.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(8),
                        PostShareRating(
                          star: posts.star,
                          color: _textColor,
                          iconSize: 16,
                          fontSize: 14,
                        ),
                        if (posts.comment.isNotEmpty) ...[
                          const Gap(8),
                          Text(
                            posts.comment,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: _textColor.withValues(alpha: 0.65),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Gap(10),
                  const PostShareMapPlaceholder(),
                ],
              ),
              const Gap(14),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PostShareImage(imageUrl: imageUrl),
                ),
              ),
              const Gap(12),
              const Center(
                child: PostShareBranding(
                  lightBackground: true,
                  showIcon: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
