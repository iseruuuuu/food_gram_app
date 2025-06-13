import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/admob/services/admob_rectangle_banner.dart';
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
    if (data.isEmpty) {
      return const AppEmpty();
    }
    final rowCount = (data.length / 3).ceil();
    const adEvery = 30;
    final adRowInterval = (adEvery / 3).floor();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final isAdRow = (index + 1) % (adRowInterval + 1) == 0;
          if (isAdRow) {
            return Container(
              // padding: const EdgeInsets.symmetric(vertical: 16),
              width: double.infinity,
              child: const Center(
                child: RectangleBanner(id: '0'),
              ),
            );
          }
          final actualRowIndex = index - (index ~/ (adRowInterval + 1));
          final startIndex = actualRowIndex * 3;
          return Row(
            children: List.generate(3, (gridIndex) {
              final itemIndex = startIndex + gridIndex;
              if (itemIndex >= data.length) {
                return const Expanded(child: SizedBox());
              }
              final itemImageUrl = supabase.storage
                  .from('food')
                  .getPublicUrl(data[itemIndex]['food_image'] as String);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    EasyDebounce.debounce(
                      'click_detail',
                      const Duration(milliseconds: 200),
                      () async {
                        final postResult = await ref
                            .read(postRepositoryProvider.notifier)
                            .getPostData(data, itemIndex);
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
                    tag: 'image-${data[itemIndex]['id']}',
                    flightShuttleBuilder: const FlipShuttleBuilder().call,
                    spring: SimpleSpring.bouncy,
                    child: Card(
                      elevation: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: itemImageUrl,
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
                ),
              );
            }),
          );
        },
        childCount: rowCount + (rowCount ~/ adRowInterval),
      ),
    );
  }
}
