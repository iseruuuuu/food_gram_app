import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/data/supabase/block_list.dart';
import 'package:food_gram_app/core/data/supabase/post_stream.dart';
import 'package:food_gram_app/core/data/supabase/service/users_service.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/main.dart';
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: deviceWidth,
        height: deviceWidth / 1.7,
        child: ListView.builder(
          itemCount: post.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                EasyDebounce.debounce(
                  'click detail',
                  Duration.zero,
                  () async {
                    final postUsers = await ref
                        .read(usersServiceProvider)
                        .getUsersFromPost(post[index]!);
                    final model = Model(postUsers, post[index]!);
                    await context
                        .pushNamed(
                      RouterPath.mapDetailPost,
                      extra: model,
                    )
                        .then((value) {
                      if (value != null) {
                        ref
                          ..invalidate(postStreamProvider)
                          ..invalidate(blockListProvider);
                      }
                    });
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                  child: Container(
                    width: deviceWidth / 1.4,
                    height: deviceWidth / 1.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(),
                        Container(
                          width: deviceWidth,
                          height: deviceWidth / 2.7,
                          child: CachedNetworkImage(
                            imageUrl: supabase.storage
                                .from('food')
                                .getPublicUrl(post[index]!.foodImage),
                            fit: BoxFit.cover,
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
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Gap(5),
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
