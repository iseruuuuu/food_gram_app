import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/data/supabase/posts_service.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/component/app_empty.dart';
import 'package:food_gram_app/ui/screen/time_line/component/story_widget.dart';
import 'package:go_router/go_router.dart';

class AppListView extends ConsumerWidget {
  const AppListView({
    required this.data,
    required this.routerPath,
    required this.refresh,
    super.key,
  });

  final List<Map<String, dynamic>> data;
  final String routerPath;
  final Function() refresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return data.isNotEmpty
        ? RefreshIndicator(
            color: Colors.black,
            onRefresh: () async {
              await Future.delayed(Duration(seconds: 1));
              refresh();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: StoryWidget(data: data),
                  ),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          EasyDebounce.debounce(
                            'click detail',
                            Duration.zero,
                            () async {
                              final post = await ref
                                  .read(postsServiceProvider)
                                  .getPost(data, index);
                              await context
                                  .pushNamed(
                                routerPath,
                                extra: post,
                              )
                                  .then((value) {
                                if (value != null) {
                                  refresh();
                                }
                              });
                            },
                          );
                        },
                        child: Card(
                          elevation: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3,
                              height: MediaQuery.of(context).size.width / 3,
                              color: Colors.white,
                              child: CachedNetworkImage(
                                imageUrl: supabase.storage
                                    .from('food')
                                    .getPublicUrl(data[index]['food_image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: data.length,
                  ),
                ),
              ],
            ),
          )
        : AppEmpty();
  }
}
