import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:go_router/go_router.dart';

class StoryWidget extends ConsumerWidget {
  const StoryWidget({
    required this.data,
    super.key,
  });

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyPosts = ref.watch(getNearByPostsProvider);
    final supabase = ref.watch(supabaseProvider);
    return nearbyPosts.when(
      data: (posts) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final imageUrl =
                supabase.storage.from('food').getPublicUrl(post.foodImage);
            return Padding(
              padding: const EdgeInsets.all(8),
              child: StoryCircle(
                imageUrl: imageUrl,
                onTap: () => _handleStoryTap(context, ref, post),
              ),
            );
          },
        );
      },
      loading: () => const AppStoryLoading(),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Future<void> _handleStoryTap(
    BuildContext context,
    WidgetRef ref,
    Posts post,
  ) async {
    // タップ処理を別メソッドに分離
    final modelListResult =
        await ref.read(postRepositoryProvider.notifier).getStoryPosts(
              lat: post.lat,
              lng: post.lng,
            );

    if (context.mounted) {
      await modelListResult.whenOrNull(
        success: (modelList) async {
          await context.pushNamed(
            RouterPath.storyPage,
            extra: modelList,
          );
        },
      );
    }
  }
}

class StoryCircle extends StatelessWidget {
  const StoryCircle({
    required this.imageUrl,
    required this.onTap,
    super.key,
  });

  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF00A5),
            Color(0xFFFE0141),
            Color(0xFFFF9F00),
            Color(0xFFFFC900),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: GestureDetector(
              onTap: onTap,
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white,
                foregroundImage: NetworkImage(imageUrl),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
