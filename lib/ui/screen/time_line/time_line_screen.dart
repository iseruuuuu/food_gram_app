import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_error_widget.dart';
import 'package:food_gram_app/ui/component/common/app_list_view.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/screen/time_line/components/category_tab.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimeLineScreen extends HookConsumerWidget {
  const TimeLineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategoryName = useState('');
    final postState =
        ref.watch(postStreamByCategoryProvider(selectedCategoryName.value));
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: Colors.black,
        onRefresh: () async {
          await Future<void>.delayed(const Duration(seconds: 1));
          ref.invalidate(
            postStreamByCategoryProvider(selectedCategoryName.value),
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const Gap(8),
                  CategoryTab(selectedCategoryName: selectedCategoryName),
                  const Gap(4),
                ],
              ),
            ),
            if (postState.hasValue)
              postState.value!.isNotEmpty
                  ? AppListView(
                      data: postState.value!,
                      routerPath: RouterPath.timeLineDetail,
                      refresh: () {
                        ref
                          ..invalidate(postStreamProvider)
                          ..invalidate(postHomeMadeStreamProvider)
                          ..invalidate(blockListProvider);
                      },
                    )
                  : const SliverToBoxAdapter(
                      child: AppEmpty(),
                    ),
            if (postState.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppContentLoading(),
              ),
            if (postState.hasError)
              SliverToBoxAdapter(
                child: AppErrorWidget(
                  onTap: () => ref.refresh(postStreamProvider),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          heroTag: null,
          foregroundColor: Colors.black,
          backgroundColor: Colors.black,
          elevation: 10,
          shape: const CircleBorder(side: BorderSide()),
          onPressed: () async {
            await context
                .pushNamed(RouterPath.timeLinePost)
                .then((value) async {
              if (value != null) {
                ref
                  ..invalidate(postStreamProvider)
                  ..invalidate(postHomeMadeStreamProvider)
                  ..invalidate(blockListProvider);
              }
            });
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 35,
          ),
        ),
      ),
    );
  }
}
