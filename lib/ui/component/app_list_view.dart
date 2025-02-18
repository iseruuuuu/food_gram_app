import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/ui/component/app_empty.dart';
import 'package:food_gram_app/ui/component/app_story_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:heroine/heroine.dart';

class AppListView extends ConsumerWidget {
  const AppListView({
    required this.data,
    required this.routerPath,
    required this.refresh,
    required this.isTimeLine,
    super.key,
  });

  final List<Map<String, dynamic>> data;
  final String routerPath;
  final VoidCallback refresh;
  final bool isTimeLine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width / 3;
    final supabase = ref.watch(supabaseProvider);
    return data.isNotEmpty
        ? RefreshIndicator(
            color: Colors.black,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              refresh();
            },
            child: CustomScrollView(
              slivers: [
                if (isTimeLine)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: AppStoryWidget(data: data),
                    ),
                  ),
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                                  .getPost(data, index);
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
                ),
              ],
            ),
          )
        : const AppEmpty();
  }
}
