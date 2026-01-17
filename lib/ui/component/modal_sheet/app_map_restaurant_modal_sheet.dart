import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class AppMapRestaurantModalSheet extends ConsumerWidget {
  const AppMapRestaurantModalSheet({
    required this.post,
    super.key,
  });

  final List<Posts?> post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final supabase = ref.watch(supabaseProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: deviceWidth,
        height: deviceWidth / 1.7,
        child: ListView.builder(
          itemCount: post.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final currentPost = post[index];
            if (currentPost == null) {
              return const SizedBox.shrink();
            }
            final images = currentPost.foodImageList;
            final imageUrls = images
                .map(
                  (path) => supabase.storage.from('food').getPublicUrl(path),
                )
                .toList();
            return GestureDetector(
              onTap: () {
                EasyDebounce.debounce(
                  'click detail',
                  Duration.zero,
                  () async {
                    final userResult = await ref
                        .read(userRepositoryProvider.notifier)
                        .getUserFromPost(post[index]!);
                    await userResult.whenOrNull(
                      success: (postUsers) async {
                        final model = Model(postUsers, post[index]!);
                        await context
                            .pushNamed(
                          RouterPath.mapDetail,
                          extra: model,
                        )
                            .then((value) {
                          if (value != null) {
                            ref
                              ..invalidate(postsStreamProvider)
                              ..invalidate(blockListProvider);
                          }
                        });
                      },
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  child: SizedBox(
                    width: deviceWidth / 1.2,
                    height: deviceWidth / 1.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        SizedBox(
                          width: deviceWidth,
                          height: deviceWidth / 2.7,
                          child: imageUrls.isEmpty
                              ? Image.asset(
                                  Assets.image.empty.path,
                                  fit: BoxFit.cover,
                                )
                              : PageView.builder(
                                  itemCount: imageUrls.length,
                                  controller: PageController(),
                                  itemBuilder: (context, pageIndex) {
                                    return CachedNetworkImage(
                                      imageUrl: imageUrls[pageIndex],
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Image.asset(
                                        Assets.image.empty.path,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                        ),
                        Container(
                          color: Colors.white,
                          width: double.infinity,
                          height: 80,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  child: Text(
                                    post[index]!.restaurant,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Gap(5),
                                FittedBox(
                                  child: Text(
                                    post[index]!.foodName,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
