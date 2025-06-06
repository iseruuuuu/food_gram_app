import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:gap/gap.dart';

class AppShareWidget extends StatelessWidget {
  const AppShareWidget({
    required this.posts,
    required this.ref,
    super.key,
  });

  final Posts posts;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final supabase = ref.watch(supabaseProvider);
    return ProviderScope(
      child: SizedBox(
        width: 350,
        height: 420,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
          elevation: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 350,
                height: 300,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: supabase.storage
                        .from('food')
                        .getPublicUrl(posts.foodImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(10),
                    Text(
                      posts.foodName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      // overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(4),
                    FittedBox(
                      child: Text(
                        'IN ${posts.restaurant}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Row(
                      children: [
                        Spacer(),
                        Text(
                          '#FoodGram',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Gap(10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
