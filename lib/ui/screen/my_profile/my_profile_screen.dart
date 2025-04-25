import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/purchase/providers/subscription_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_app_bar.dart';
import 'package:food_gram_app/ui/component/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/app_empty.dart';
import 'package:food_gram_app/ui/component/app_floating_button.dart';
import 'package:food_gram_app/ui/component/app_header.dart';
import 'package:food_gram_app/ui/component/app_list_view.dart';
import 'package:food_gram_app/ui/component/app_skeleton.dart';
import 'package:food_gram_app/ui/component/dialog/app_promote_dialog.dart';
import 'package:food_gram_app/ui/screen/my_profile/my_profile_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyProfileScreen extends HookConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myPostStreamProvider);
    final users = ref.watch(myProfileViewModelProvider());
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
        backgroundColor: Colors.white,
        appBar: const AppAppBar(),
        body: AsyncValueSwitcher(
          asyncValue: state,
          onErrorTap: () {
            ref
              ..invalidate(myPostStreamProvider)
              ..invalidate(subscriptionProvider);
            ref.read(myProfileViewModelProvider().notifier).getData();
          },
          onData: (value) {
            return RefreshIndicator(
              color: Colors.black,
              onRefresh: () async {
                await Future<void>.delayed(const Duration(seconds: 1));
                ref.invalidate(myPostStreamProvider);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: users.when(
                      data: (users, length, heartAmount) {
                        return AppHeader(
                          users: users,
                          length: length,
                          heartAmount: heartAmount,
                        );
                      },
                      loading: () {
                        return const AppHeaderSkeleton();
                      },
                      error: SizedBox.shrink,
                    ),
                  ),
                  if (value.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 8),
                      sliver: AppListView(
                        data: value,
                        routerPath: RouterPath.myProfileDetail,
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
        floatingActionButton: AppFloatingButton(
          onTap: () async {
            await context
                .pushNamed(RouterPath.myProfilePost)
                .then((value) async {
              if (value != null) {
                ref.invalidate(myPostStreamProvider);
              }
            });
          },
        ),
      ),
    );
  }
}
