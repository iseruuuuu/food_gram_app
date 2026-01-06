import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/services/detail_post_service.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/profile/app_profile_image.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserSearchTab extends ConsumerWidget {
  const UserSearchTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    final usersWithPostCount = ref.watch(usersWithPostCountProviderProvider);
    final supabase = ref.watch(supabaseProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.person, size: 20),
                const Gap(8),
                Text(
                  l10n.searchUserHeader,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: usersWithPostCount.when(
              data: (users) {
                final filteredUsers = users;
                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final userData = Users.fromJson(user);
                    final latestPosts = user['latest_posts'] as List<dynamic>;
                    final postCount = user['post_count'] as int;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.pushNamed(
                                  RouterPath.timeLineProfile,
                                  extra: userData,
                                );
                              },
                              child: Row(
                                children: [
                                  AppProfileImage(
                                    imagePath: userData.image,
                                    radius: 28,
                                  ),
                                  const Gap(12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userData.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          l10n.searchUserPostCount(
                                            postCount.toString(),
                                          ),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(16),
                            if (latestPosts.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.searchUserLatestPosts,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(8),
                              SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: latestPosts.length,
                                  itemBuilder: (context, postIndex) {
                                    final post = latestPosts[postIndex]
                                        as Map<String, dynamic>;
                                    final postId = post['id'] as int?;
                                    final foodImage =
                                        post['food_image'] as String? ?? '';
                                    final imagePaths = foodImage.isNotEmpty
                                        ? foodImage
                                            .split(',')
                                            .where((p) => p.isNotEmpty)
                                            .toList()
                                        : <String>[];
                                    final firstImage = imagePaths.isNotEmpty
                                        ? imagePaths.first
                                        : '';
                                    final hasMultipleImages =
                                        imagePaths.length > 1;
                                    // 画像パスが空の場合は安全にプレースホルダーを表示
                                    if (firstImage.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                        ),
                                      );
                                    }
                                    final imageUrl = supabase.storage
                                        .from('food')
                                        .getPublicUrl(firstImage);
                                    return GestureDetector(
                                      onTap: postId == null
                                          ? null
                                          : () async {
                                              final detailService = ref.read(
                                                detailPostServiceProvider
                                                    .notifier,
                                              );
                                              final result = await detailService
                                                  .getPost(postId);
                                              result.when(
                                                success: (data) {
                                                  final posts = Posts.fromJson(
                                                    data['post']
                                                        as Map<String, dynamic>,
                                                  );
                                                  final users = Users.fromJson(
                                                    data['user']
                                                        as Map<String, dynamic>,
                                                  );
                                                  context.pushNamed(
                                                    RouterPath.searchDetailPost,
                                                    extra: Model(users, posts),
                                                  );
                                                },
                                                failure: (error) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        l10n.error,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey[200],
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  width: 80,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      8,
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (hasMultipleImages)
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.6),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.collections,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const AppContentLoading(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
