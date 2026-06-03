import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/ui/component/share/post_share_branding.dart';
import 'package:food_gram_app/ui/component/share/post_share_image.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostShareStoryTemplate extends StatelessWidget {
  const PostShareStoryTemplate({
    required this.posts,
    required this.ref,
    super.key,
  });

  final Posts posts;
  final WidgetRef ref;

  static const Size size = Size(360, 640);

  @override
  Widget build(BuildContext context) {
    final supabase = ref.watch(supabaseProvider);
    final imageUrl =
        supabase.storage.from('food').getPublicUrl(posts.firstFoodImage);
    final foodNameLines = _splitFoodName(posts.foodName);

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
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: size.height * 0.35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: size.height * 0.4,
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
                top: 18,
                right: 18,
                child: Row(
                  children: const [
                    _StorySegment(isActive: true),
                    Gap(4),
                    _StorySegment(isActive: false),
                    Gap(4),
                    _StorySegment(isActive: false),
                  ],
                ),
              ),
              Positioned(
                top: 48,
                left: 22,
                right: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final line in foodNameLines)
                      Text(
                        line,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                    const Gap(8),
                    Text(
                      'IN ${posts.restaurant}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                bottom: 24,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Spacer(),
                    const Gap(12),
                    const PostShareBranding(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _splitFoodName(String foodName) {
    final trimmed = foodName.trim();
    if (trimmed.isEmpty) {
      return const [];
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length <= 1) {
      return [trimmed];
    }
    if (parts.length == 2) {
      return parts;
    }
    final midpoint = (parts.length / 2).ceil();
    return [
      parts.sublist(0, midpoint).join(' '),
      parts.sublist(midpoint).join(' '),
    ];
  }
}

class _StorySegment extends StatelessWidget {
  const _StorySegment({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 3,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white
            : Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
