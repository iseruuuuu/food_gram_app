import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';

class AppStoryWidget extends ConsumerWidget {
  const AppStoryWidget({
    required this.data,
    super.key,
  });

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyPosts = ref.watch(getNearByPostsProvider);
    return nearbyPosts.when(
      data: (posts) {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Padding(
              padding: const EdgeInsets.all(8),
              child: DecoratedBox(
                decoration: BoxDecoration(
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
                  padding: EdgeInsets.all(3),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(3),
                      child: GestureDetector(
                        onTap: () async {
                          //TODO 同じレストランの場合に複数見れるようにする
                          final modelListResult = await ref
                              .read(postRepositoryProvider.notifier)
                              .getRandomPosts(data, index);
                          await modelListResult.whenOrNull(
                            success: (modelList) async {
                              await context.pushNamed(
                                RouterPath.storyPage,
                                extra: modelList,
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          foregroundImage: NetworkImage(
                            supabase.storage
                                .from('food')
                                .getPublicUrl(post.foodImage),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
