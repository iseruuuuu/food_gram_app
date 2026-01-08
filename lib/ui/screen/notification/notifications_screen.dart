import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/notification/repository/notification_repository.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myLikeNotificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.of(context).likeNotificationsTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close, size: 32, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(
          child: Text(
            L10n.of(context).loadFailed,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const AppEmpty();
          }
          final supabase = ref.watch(supabaseProvider);
          final posts = notifications.map((n) => n.post).toList();
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final n = notifications[index];
              final post = n.post;
              final imageUrl = supabase.storage
                  .from('food')
                  .getPublicUrl(post.firstFoodImage);
              final likerUserId = n.likerUserId;
              return ListTile(
                onTap: () async {
                  final postResult = await ref
                      .read(detailPostRepositoryProvider.notifier)
                      .getPostData(posts, index);
                  final result = await postResult.whenOrNull(
                    success: (model) => context.pushNamed(
                      RouterPath.myProfileDetail,
                      extra: model,
                    ),
                  );
                  if (result != null) {
                    final _ = ref.refresh(myLikeNotificationsProvider);
                  }
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: likerUserId == null
                    ? Text(L10n.of(context).someoneLikedYourPost)
                    : FutureBuilder<Map<String, dynamic>>(
                        future: ref
                            .read(detailPostRepositoryProvider.notifier)
                            .getUserData(likerUserId),
                        builder: (context, snapshot) {
                          final name = (snapshot.data != null
                                  ? snapshot.data!['name'] as String?
                                  : null) ??
                              '誰か';
                          return Text(
                            L10n.of(context).userLikedYourPost(name),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                trailing: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
