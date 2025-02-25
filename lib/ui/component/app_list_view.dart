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
    final displayedData = useState(data.take(30).toList());

    useEffect(
      () {
        void onScroll() {
          if (!scrollController.hasClients) return;

          if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 500) {
            final currentLength = displayedData.value.length;
            if (currentLength < data.length) {
              displayedData.value = [
                ...displayedData.value,
                ...data.skip(currentLength).take(30),
              ];
            }
          }
          final scrollPosition = scrollController.position.pixels;
          final viewportHeight = scrollController.position.viewportDimension;
          ref.read(currentAdPositionProvider.notifier).state =
              _calculateScrollSize(
            context,
            scrollPosition,
            viewportHeight,
          );
        }

        scrollController.addListener(onScroll);
        return () => scrollController.removeListener(onScroll);
      },
      [scrollController],
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
                    chunk < (displayedData.value.length / 30).ceil();
                    chunk++) ...[
                  SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final actualIndex = (chunk * 30) + index;
                        if (actualIndex >= displayedData.value.length) {
                          return null;
                        }
                        final foodImageUrl = supabase.storage
                            .from('food')
                            .getPublicUrl(
                                displayedData.value[actualIndex]['food_image']);
                        return GestureDetector(
                          onTap: () {
                            EasyDebounce.debounce(
                              'click_detail',
                              const Duration(milliseconds: 200),
                              () async {
                                final postResult = await ref
                                    .read(postRepositoryProvider.notifier)
                                    .getPostData(data, actualIndex);
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
                            tag:
                                'image-${displayedData.value[actualIndex]['id']}',
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
                      childCount:
                          min(30, displayedData.value.length - (chunk * 30)),
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                  ),
                  if (chunk < (displayedData.value.length / 30).ceil() - 1)
                    SliverToBoxAdapter(
                      child: ReusableRectangleBanner(
                        position: chunk,
                      ),
                    ),
                ],
              ],
            ),
          )
        : const AppEmpty();
  }
}

int _calculateScrollSize(
  BuildContext context,
  double scrollPosition,
  double viewportHeight,
) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth <= 375) {
    return (scrollPosition / (viewportHeight * 3)).floor();
  } else if (screenWidth < 720) {
    return (scrollPosition / (viewportHeight * 2.4)).floor();
  } else {
    return (scrollPosition / (viewportHeight * 3)).floor();
  }
}
