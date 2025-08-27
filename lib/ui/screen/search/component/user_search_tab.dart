import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
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
                    final postCount = user['post_count'] as int;
                    final latestPosts = user['latest_posts'] as List<dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
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
                                    final imageUrl = supabase.storage
                                        .from('food')
                                        .getPublicUrl(
                                          post['food_image'] as String,
                                        );
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
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
