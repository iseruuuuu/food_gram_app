import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/post_count_rank_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/core/utils/user_level.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_premium_membership_card.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_list_view.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/common/app_skeleton.dart';
import 'package:food_gram_app/ui/component/common/app_tab_loading.dart';
import 'package:food_gram_app/ui/component/dialog/app_level_up_dialog.dart';
import 'package:food_gram_app/ui/component/dialog/app_promote_dialog.dart';
import 'package:food_gram_app/ui/screen/profile/components/profile_header.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/my_profile_view_model.dart';
import 'package:food_gram_app/ui/screen/tab/use_scroll_to_top_on_tab_trigger.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyProfileScreen extends HookConsumerWidget {
  const MyProfileScreen({super.key});

  static const int _tabIndex = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postList = ref.watch(myPostStreamProvider);
    final postCount = postList.valueOrNull?.length ?? 0;
    final users = ref.watch(myProfileViewModelProvider());
    final scrollController = useScrollController();
    final hasData = postList.valueOrNull != null;
    useScrollToTopOnTabTrigger(
      ref: ref,
      scrollController: scrollController,
      tabIndex: _tabIndex,
      extraDeps: [hasData],
    );
    final isSubscribeAsync = ref.watch(isSubscribeProvider);
    final loading = ref.watch(loadingProvider);
    useEffect(() {
      users.whenOrNull(
        data: (users, ___) {
          if (users.isSubscribe) {
            return;
          }
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final value = math.Random().nextInt(10);
            if (value == 0) {
              await showDialog<void>(
                context: context,
                builder: (context) => const AppPromoteDialog(),
              );
            }
          });
        },
      );
      return null;
    });
    return Stack(
      children: [
        DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                Translations.of(context).tab.myPage,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () =>
                      context.pushNamed(RouterPath.wantToGoList),
                  icon: Icon(
                    Icons.place_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      context.pushNamed(RouterPath.storedPost),
                  icon: Icon(
                    Icons.bookmark_border,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      context.pushNamed(RouterPath.notifications),
                  icon: const Icon(
                    Icons.favorite_border,
                    color: Colors.red,
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
                return RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  onRefresh: () async {
                    await Future<void>.delayed(const Duration(seconds: 1));
                    ref.invalidate(myPostStreamProvider);
                    final uid = ref.read(currentUserProvider);
                    if (uid != null) {
                      ref.invalidate(postCountRankProvider(uid));
                    }
                    await ref
                        .read(myProfileViewModelProvider().notifier)
                        .getData();
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
                            final premiumUnlocked = users.isSubscribe ||
                                (isSubscribeAsync.valueOrNull ?? false);
                            return Column(
                              children: [
                                if (!premiumUnlocked)
                                  const AppPremiumMembershipCard(),
                                AppProfileHeader(
                                  users: users,
                                  length: postCount,
                                  heartAmount: heartAmount,
                                  rankingUnlockedOverride: premiumUnlocked,
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
                      if (value.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 8),
                          sliver: AppListView(
                            posts: value,
                            routerPath: RouterPath.myProfileDetail,
                            type: AppListViewType.myprofile,
                            controller: scrollController,
                            refresh: () => ref.refresh(myPostStreamProvider),
                          ),
                        )
                      else
                        const SliverToBoxAdapter(
                          child: AppEmpty(),
                        ),
                    ],
                  ),
                );
              },
            ),
            floatingActionButton: Builder(
              builder: (context) {
                return SizedBox(
                  width: 70,
                  height: 70,
                  child: FloatingActionButton(
                    heroTag: null,
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: AppTheme.fabBorderColor(context),
                      ),
                    ),
                    onPressed: () async {
                      final oldPostCount =
                          ref.read(myPostStreamProvider).valueOrNull?.length ??
                              0;
                      final result =
                          await context.pushNamed(RouterPath.myProfilePost);
                      if (result != null) {
                        ref.invalidate(myPostStreamProvider);
                        final uid = ref.read(currentUserProvider);
                        if (uid != null) {
                          ref.invalidate(postCountRankProvider(uid));
                        }
                        await ref.read(myPostStreamProvider.future);
                        final newPostCount = ref
                                .read(myPostStreamProvider)
                                .valueOrNull
                                ?.length ??
                            0;
                        if (UserLevel.levelFromPostCount(newPostCount) >
                                UserLevel.levelFromPostCount(oldPostCount) &&
                            context.mounted) {
                          await showLevelUpDialog(
                            context: context,
                            level: UserLevel.levelFromPostCount(newPostCount),
                          );
                        }
                      }
                    },
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 35,
                    ),
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
