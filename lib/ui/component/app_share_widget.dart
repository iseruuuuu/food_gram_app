import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // 背景画像
                SizedBox.expand(
                  child: CachedNetworkImage(
                    imageUrl: supabase.storage
                        .from('food')
                        .getPublicUrl(posts.foodImage),
                    fit: BoxFit.cover,
                  ),
                ),
                // グラデーションオーバーレイ（下部）
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
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
                // テキスト情報（下部に配置）
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          posts.foodName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        FittedBox(
                          child: Text(
                            'IN ${posts.restaurant}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            const Spacer(),
                            const Text(
                              '#FoodGram',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Gap(4),
                            Assets.icon.icon3.image(
                              width: 30,
                              height: 30,
                            ),
                          ],
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
  }
}
