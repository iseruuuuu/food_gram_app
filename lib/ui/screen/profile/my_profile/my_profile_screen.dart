import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/notification/like_notification_seen.dart';
import 'package:food_gram_app/core/supabase/notification/repository/notification_repository.dart';
import 'package:food_gram_app/core/supabase/post/providers/liked_post_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/post_count_rank_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/theme/style/profile_style.dart';
import 'package:food_gram_app/core/utils/my_profile_post_sort.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_premium_membership_card.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_list_view.dart';
import 'package:food_gram_app/ui/component/common/app_tab_error.dart';
import 'package:food_gram_app/ui/component/loading/app_overlay_loading.dart';
import 'package:food_gram_app/ui/component/loading/app_skeleton.dart';
import 'package:food_gram_app/ui/component/loading/app_tab_loading.dart';
import 'package:food_gram_app/ui/screen/profile/components/profile_header.dart';
import 'package:food_gram_app/ui/screen/profile/components/profile_sort_chip_bar.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/my_profile_state.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/my_profile_view_model.dart';
import 'package:food_gram_app/ui/screen/tab/tab_screen.dart';
import 'package:food_gram_app/ui/screen/tab/tab_state.dart';
import 'package:food_gram_app/ui/screen/tab/tab_view_model.dart';
import 'package:food_gram_app/ui/screen/tab/use_scroll_to_top_on_tab_trigger.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyProfileScreen extends HookConsumerWidget {
  const MyProfileScreen({super.key});

  static const int _tabIndex = TabIndex.myPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postList = ref.watch(myPostStreamProvider);
    final postCount = postList.value?.length ?? 0;
    final users = ref.watch(myProfileViewModelProvider());
    final sortOrder = useState(MyProfilePostSortOrder.newest);
    final showingLiked = sortOrder.value == MyProfilePostSortOrder.likedPlaces;
    final likedAsync = showingLiked ? ref.watch(likedPostListProvider) : null;
    final scrollController = useScrollController();
    final hasData = postList.value != null;
    useScrollToTopOnTabTrigger(
      ref: ref,
      scrollController: scrollController,
      tabIndex: _tabIndex,
      extraDeps: [hasData],
    );
    final isSubscribeAsync = ref.watch(isSubscribeProvider);
    final hasUnseenLikes = ref.watch(hasUnseenLikeNotificationsProvider);
    final selectedTab = ref.watch(
      tabViewModelProvider().select((state) => state.selectedIndex),
    );
    final hasOpenedMyPage = useRef(false);
    useEffect(
      () {
        if (selectedTab != TabIndex.myPage) {
          return null;
        }
        if (!hasOpenedMyPage.value) {
          hasOpenedMyPage.value = true;
          return null;
        }
        var active = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!active) {
            return;
          }
          ref.invalidate(myLikeNotificationsProvider);
        });
        return () {
          active = false;
        };
      },
      [selectedTab],
    );
    final loading = ref.watch(loadingProvider);
    // フローティングボトムナビの下に最終行が隠れないよう、末尾に余白を確保する
    final bottomInset = TabScreen.bottomNavOccupiedHeight(context) + 30;
    return Stack(
      children: [
        DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.backgroundOf(context),
              surfaceTintColor: AppTheme.backgroundOf(context),
              elevation: 0,
              centerTitle: true,
              leadingWidth: 96,
              leading: Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        context.pushNamed(RouterPath.notifications),
                    icon: Icon(
                      hasUnseenLikes ? Icons.favorite : Icons.favorite_border,
                      color: hasUnseenLikes
                          ? AppTheme.primaryOrange
                          : AppTheme.textSecondaryOf(context),
                    ),
                  ),
                  IconButton(
                    tooltip: Translations.of(context).tagDex.title,
                    onPressed: () => context.pushNamed(RouterPath.tagDex),
                    icon: Icon(
                      Icons.menu_book_outlined,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                ],
              ),
              title: Text(
                Translations.of(context).tab.myPage,
                style: ProfileStyle.screenTitle(context),
              ),
              actions: [
                IconButton(
                  onPressed: () => context.pushNamed(RouterPath.wantToGoList),
                  icon: Icon(
                    Icons.bookmark_added_sharp,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                IconButton(
                  onPressed: () => context.pushNamed(RouterPath.setting),
                  icon: Icon(
                    Icons.settings_outlined,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
              ],
            ),
            body: AsyncValueSwitcher(
              asyncValue: postList,
              onLoading: const AppTabLoading.myPage(),
              errorType: TabLoadingType.myPage,
              skipError: true,
              onErrorTap: () {
                ref
                  ..invalidate(myPostStreamProvider)
                  ..invalidate(isSubscribeProvider);
                ref.read(myProfileViewModelProvider().notifier).getData();
              },
              onData: (value) {
                final sortedPosts = showingLiked
                    ? const <Posts>[]
                    : sortMyProfilePosts(value, sortOrder.value);
                return RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  onRefresh: () async {
                    ref
                      ..invalidate(myPostStreamProvider)
                      ..invalidate(myLikeNotificationsProvider)
                      ..invalidate(likedPostIdsProvider);
                    final uid = ref.read(currentUserProvider);
                    if (uid != null) {
                      ref.invalidate(postCountRankProvider(uid));
                    }
                    try {
                      await Future.wait<void>([
                        ref
                            .read(myPostStreamProvider.future)
                            .then<void>((_) {}),
                        ref
                            .read(myProfileViewModelProvider().notifier)
                            .getData(),
                        if (showingLiked)
                          ref
                              .read(likedPostListProvider.future)
                              .then<void>(
                                (_) {},
                              ),
                      ]);
                    } on Object {
                      // 再取得失敗時もインジケータは閉じる
                    }
                  },
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: users.when(
                          data: (users, heartAmount) {
                            final premiumUnlocked =
                                users.isSubscribe ||
                                (isSubscribeAsync.value ?? false);
                            return Column(
                              children: [
                                if (!premiumUnlocked)
                                  const AppPremiumMembershipCard(
                                    source: 'my_page_card',
                                  ),
                                AppProfileHeader(
                                  users: users,
                                  length: postCount,
                                  heartAmount: heartAmount,
                                ),
                              ],
                            );
                          },
                          loading: () {
                            return const AppProfileHeaderSkeleton();
                          },
                          error: SizedBox.shrink,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: ProfileSortChipBar(
                          selectedSort: sortOrder.value,
                          onSortChanged: (order) {
                            sortOrder.value = order;
                            if (scrollController.hasClients) {
                              scrollController.jumpTo(0);
                            }
                          },
                        ),
                      ),
                      if (showingLiked)
                        ..._likedPostSlivers(
                          context: context,
                          ref: ref,
                          likedAsync: likedAsync!,
                          bottomInset: bottomInset,
                          scrollController: scrollController,
                        )
                      else if (sortedPosts.isNotEmpty)
                        SliverPadding(
                          padding: EdgeInsets.only(top: 4, bottom: bottomInset),
                          sliver: AppListView(
                            posts: sortedPosts,
                            routerPath: RouterPath.myProfileDetail,
                            type: AppListViewType.myprofile,
                            controller: scrollController,
                            sortOrder: sortOrder.value,
                            refresh: () => ref.refresh(myPostStreamProvider),
                          ),
                        )
                      else
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: bottomInset),
                            child: const AppMyPostEmpty(),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        AppProcessLoading(
          loading: loading,
          status: 'Loading...',
        ),
      ],
    );
  }
}

List<Widget> _likedPostSlivers({
  required BuildContext context,
  required WidgetRef ref,
  required AsyncValue<List<Posts>> likedAsync,
  required double bottomInset,
  required ScrollController scrollController,
}) {
  return likedAsync.when(
    skipLoadingOnReload: true,
    skipLoadingOnRefresh: true,
    loading: () => const [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryOrange,
          ),
        ),
      ),
    ],
    error: (_, _) => [
      SliverFillRemaining(
        hasScrollBody: false,
        child: AppTabError.myPage(
          onRetry: () => ref.invalidate(likedPostIdsProvider),
        ),
      ),
    ],
    data: (posts) {
      if (posts.isEmpty) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(28, 24, 28, bottomInset),
              child: Center(
                child: Text(
                  Translations.of(context).profile.likedPlacesEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ];
      }
      return [
        SliverPadding(
          padding: EdgeInsets.only(top: 4, bottom: bottomInset),
          sliver: AppListView(
            posts: posts,
            routerPath: RouterPath.likedPostDetail,
            type: AppListViewType.stored,
            controller: scrollController,
            refresh: () => ref.invalidate(likedPostIdsProvider),
          ),
        ),
      ];
    },
  );
}
