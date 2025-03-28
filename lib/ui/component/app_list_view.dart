import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/ui/component/app_empty.dart';
import 'package:go_router/go_router.dart';
import 'package:heroine/heroine.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppListView extends HookConsumerWidget {
  const AppListView({
    required this.data,
    required this.routerPath,
    required this.refresh,
    super.key,
  });

  final List<Map<String, dynamic>> data;
  final String routerPath;
  final VoidCallback refresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width / 3;
    final supabase = ref.watch(supabaseProvider);
    return data.isNotEmpty
        ? SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= data.length) {
                  return null;
                }
                final foodImageUrl = supabase.storage
                    .from('food')
                    .getPublicUrl(data[index]['food_image']);
                return GestureDetector(
                  onTap: () {
                    EasyDebounce.debounce(
                      'click_detail',
                      const Duration(milliseconds: 200),
                      () async {
                        final postResult = await ref
                            .read(postRepositoryProvider.notifier)
                            .getPostData(data, index);
                        await postResult.whenOrNull(
                          success: (model) async {
                            final result = await context.pushNamed(
                              routerPath,
                              extra: model,
                            );
                            if (result != null) {
                              refresh();
                            }
                          },
                        );
                      },
                    );
                  },
                  child: Heroine(
                    tag: 'image-${data[index]['id']}',
                    flightShuttleBuilder: FlipShuttleBuilder(),
                    spring: SimpleSpring.bouncy,
                    child: Card(
                      elevation: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: foodImageUrl,
                          fit: BoxFit.cover,
                          width: screenWidth,
                          height: screenWidth,
                          placeholder: (context, url) => Container(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: data.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
          )
        : AppEmpty();
  }
}
