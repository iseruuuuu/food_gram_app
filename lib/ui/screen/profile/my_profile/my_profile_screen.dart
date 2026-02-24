import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/utils/user_level.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_premium_membership_card.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_list_view.dart';
import 'package:food_gram_app/ui/component/common/app_skeleton.dart';
import 'package:food_gram_app/ui/component/dialog/app_level_up_dialog.dart';
import 'package:food_gram_app/ui/component/dialog/app_promote_dialog.dart';
import 'package:food_gram_app/ui/component/profile/app_profile_header.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/my_profile_view_model.dart';
import 'package:food_gram_app/ui/screen/tab/use_scroll_to_top_on_tab_trigger.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyProfileScreen extends HookConsumerWidget {
  const MyProfileScreen({super.key});

  static const int _tabIndex = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myPostStreamProvider);
    final users = ref.watch(myProfileViewModelProvider());
    final scrollController = useScrollController();
    final hasData = state.valueOrNull != null;
    useScrollToTopOnTabTrigger(
      ref: ref,
      scrollController: scrollController,
      tabIndex: _tabIndex,
      extraDeps: [hasData],
    );
    final isSubscribeAsync = ref.watch(isSubscribeProvider);
    final isSubscribed = isSubscribeAsync.valueOrNull ?? false;
    useEffect(() {
      users.whenOrNull(
        data: (users, __, ___) {
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            surfaceTintColor: Colors.transparent,
            forceMaterialTransparency: true,
            elevation: 0,
          ),
        ),
        body: AsyncValueSwitcher(
          asyncValue: state,
          onErrorTap: () {
            ref
              ..invalidate(myPostStreamProvider)
              ..invalidate(isSubscribeProvider);
            ref.read(myProfileViewModelProvider().notifier).getData();
          },
          onData: (value) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final surfaceColor = isDark ? Colors.black : Colors.white;
            return RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              onRefresh: () async {
                await Future<void>.delayed(const Duration(seconds: 1));
                ref.invalidate(myPostStreamProvider);
              },
              child: CustomScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: users.when(
                      data: (users, length, heartAmount) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AppProfileHeader(
                              users: users,
                              length: length,
                              heartAmount: heartAmount,
                            ),
                            if (!isSubscribed)
                              const Positioned(
                                top: 10,
                                left: 0,
                                right: 0,
                                child: AppPremiumMembershipCard(),
                              ),
                            // ヘッダー右上の操作群（通知・保存）
                            Positioned(
                              top: !isSubscribed ? 70 : 10,
                              right: 12,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Material(
                                    color: surfaceColor,
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(20),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => context
                                          .pushNamed(RouterPath.storedPost),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.bookmark,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              Translations.of(context)
                                                  .stored
                                                  .savedPosts,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Material(
                                    color: surfaceColor,
                                    shape: const CircleBorder(),
                                    elevation: 4,
                                    child: IconButton(
                                      onPressed: () {
                                        context.pushNamed(
                                          RouterPath.notifications,
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.favorite_border,
                                        color: Colors.red,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
            final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onPressed: () async {
                  final vm = ref.read(myProfileViewModelProvider().notifier);
                  final oldPostCount = ref
                      .read(myProfileViewModelProvider())
                      .whenOrNull(data: (_, length, __) => length) ?? 0;
                  final result =
                      await context.pushNamed(RouterPath.myProfilePost);
                  if (result != null) {
                    ref.invalidate(myPostStreamProvider);
                    await vm.getData();
                    final newPostCount = ref
                        .read(myProfileViewModelProvider())
                        .whenOrNull(data: (_, length, __) => length) ?? 0;
                    final oldLevel = UserLevel.levelFromPostCount(oldPostCount);
                    final newLevel =
                        UserLevel.levelFromPostCount(newPostCount);
                    if (newLevel > oldLevel && context.mounted) {
                      await showLevelUpDialog(
                        context: context,
                        level: newLevel,
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
    );
  }
}
