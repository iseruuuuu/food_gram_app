import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_banner.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/ui/component/app_empty.dart';
import 'package:food_gram_app/ui/component/app_story_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:heroine/heroine.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppListView extends HookConsumerWidget {
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
    final scrollController = useScrollController();
    useEffect(
      () {
        void onScroll() {
          if (!scrollController.hasClients) {
            return;
          }
          final scrollPosition = scrollController.position.pixels;
          final viewportHeight = scrollController.position.viewportDimension;
          final adPosition = (scrollPosition / (viewportHeight * 2.4)).floor();
          ref.read(currentAdPositionProvider.notifier).state = adPosition;
        }

        scrollController.addListener(onScroll);
        return () => scrollController.removeListener(onScroll);
      },
      [scrollController],
    );

    // 画像URLのメモ化
    final getImageUrl = useCallback(
      (index) {
        return supabase.storage
            .from('food')
            .getPublicUrl(data[index]['food_image']);
      },
      [data],
    );
    return data.isNotEmpty
        ? RefreshIndicator(
            color: Colors.black,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              refresh();
            },
            child: CustomScrollView(
              controller: scrollController,
              cacheExtent: 500,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                if (isTimeLine)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      width: double.infinity,
                      height: 100,
                      child: AppStoryWidget(data: data),
                    ),
                  ),
                for (int chunk = 0;
                    chunk < (data.length / 30).ceil();
                    chunk++) ...[
                  SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final actualIndex = (chunk * 30) + index;
                        if (actualIndex >= data.length) {
                          return null;
                        }
                        final foodImageUrl = getImageUrl(actualIndex);
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
                      childCount: min(30, data.length - (chunk * 30)),
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                  ),
                  if (chunk < (data.length / 30).ceil() - 1)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ReusableRectangleBanner(
                          position: chunk,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          )
        : const AppEmpty();
  }
}
