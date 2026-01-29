import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_banner.dart';
import 'package:food_gram_app/core/model/post_deail_list_mode.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/i18n/strings.g.dart';
import 'package:food_gram_app/ui/component/app_heart.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/common/app_skeleton.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_master_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_my_info_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_other_info_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/post_detail/component/post_detail_list_item.dart';
import 'package:food_gram_app/ui/screen/post_detail/post_detail_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostDetailScreen extends HookConsumerWidget {
  const PostDetailScreen({
    required this.posts,
    required this.users,
    required this.type,
    super.key,
  });

  final Posts posts;
  final Users users;
  final PostDetailScreenType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final memoizedPosts = useMemoized(() => posts, [posts.id]);
    useEffect(
      () {
        ref
            .read(postDetailViewModelProvider().notifier)
            .initializeStoreState(posts.id);
        ref
            .read(postDetailViewModelProvider().notifier)
            .initializeHeartState(posts.id, posts.heart);
        return;
      },
      [posts.id],
    );
    final t = Translations.of(context);
    final menuLoading = useState(false);
    final loading = ref.watch(loadingProvider);
    final currentUser = ref.watch(currentUserProvider);
    final detailState = ref.watch(postDetailViewModelProvider());
    final listState = ref.watch(
      postDetailListProvider(
        PostDetailListInput(
          initialPost: memoizedPosts,
          mode: switch (type) {
            PostDetailScreenType.timeline => PostDetailListMode.timeline,
            PostDetailScreenType.myprofile => PostDetailListMode.myprofile,
            PostDetailScreenType.profile => PostDetailListMode.profile,
            PostDetailScreenType.map => PostDetailListMode.nearby,
            PostDetailScreenType.search => PostDetailListMode.search,
            PostDetailScreenType.stored => PostDetailListMode.stored,
          },
          profileUserId:
              type == PostDetailScreenType.profile ? users.userId : null,
          restaurant:
              type == PostDetailScreenType.search ? posts.restaurant : null,
        ),
      ),
    );
    final isInitialLoading = listState.isLoading;
    return PopScope(
      canPop: !(loading || isInitialLoading),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: !(loading || isInitialLoading),
          surfaceTintColor: Colors.transparent,
          leading: loading || menuLoading.value || isInitialLoading
              ? const SizedBox.shrink()
              : GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(
                    Icons.close,
                    size: 30,
                  ),
                ),
          actions: [
            if (!loading && !menuLoading.value && !isInitialLoading)
              IconButton(
                onPressed: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    builder: (context) {
                      if (currentUser == Env.masterAccount) {
                        return AppDetailMasterModalSheet(
                          posts: posts,
                          users: users,
                          delete: (posts) async {
                            await ref
                                .read(postDetailViewModelProvider().notifier)
                                .delete(posts);
                          },
                        );
                      }
                      if (users.userId != currentUser) {
                        return AppDetailOtherInfoModalSheet(
                          users: users,
                          posts: posts,
                          loading: menuLoading,
                          block: (userId) async {
                            return ref
                                .read(postDetailViewModelProvider().notifier)
                                .block(userId);
                          },
                        );
                      } else {
                        return AppDetailMyInfoModalSheet(
                          users: users,
                          posts: posts,
                          loading: menuLoading,
                          delete: (posts) async {
                            await ref
                                .read(postDetailViewModelProvider().notifier)
                                .delete(posts);
                          },
                          setUser: (posts) {
                            ref
                                .read(
                                  postsViewModelProvider(posts.id).notifier,
                                )
                                .setUser(posts);
                          },
                        );
                      }
                    },
                  );
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              listState.when(
                loading: () => const AppPostDetailSkeleton(),
                error: (error, stack) => const Center(
                  child: Text('エラーが発生しました'),
                ),
                data: (posts) => ListView.builder(
                  controller: scrollController,
                  key: PageStorageKey('post_detail_list_${memoizedPosts.id}'),
                  restorationId: 'post_detail_list_${memoizedPosts.id}',
                  cacheExtent: 2000,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostDetailListItem(
                      key: ValueKey('post_${post.id}'),
                      posts: post,
                      menuLoading: menuLoading,
                      onHeartLimitReached: () {
                        SnackBarHelper().openWarningSnackBar(
                          context,
                          t.heartLimitMessage,
                        );
                      },
                    );
                  },
                ),
              ),
              AppHeart(isHeart: detailState.isAppearHeart),
              AppProcessLoading(
                loading: menuLoading.value || loading,
                status: 'Loading...',
              ),
            ],
          ),
        ),
        bottomNavigationBar: isInitialLoading
            ? null
            : const SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8, top: 4),
                  child: AdmobBanner(id: 'detail_footer'),
                ),
              ),
      ),
    );
  }
}

enum PostDetailScreenType {
  timeline,
  myprofile,
  profile,
  stored,
  map,
  search,
}
