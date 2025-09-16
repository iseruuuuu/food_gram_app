import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_card_list_item.dart';
import 'package:go_router/go_router.dart';

class SearchDetailScreen extends ConsumerWidget {
  const SearchDetailScreen({
    required this.posts,
    super.key,
  });

  final List<Posts> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return AppCardListItem(
              post: posts[index],
              index: index,
              onTap: () {
                context.goNamed(
                  RouterPath.searchRestaurantReview,
                  extra: posts[index],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
