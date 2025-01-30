import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/data/purchase/subscription_provider.dart';
import 'package:food_gram_app/core/data/supabase/post_stream.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_app_bar.dart';
import 'package:food_gram_app/ui/component/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/app_floating_button.dart';
import 'package:food_gram_app/ui/component/app_header.dart';
import 'package:food_gram_app/ui/component/app_list_view.dart';
import 'package:food_gram_app/ui/component/app_profile_button.dart';
import 'package:food_gram_app/ui/component/app_skeleton.dart';
import 'package:food_gram_app/ui/screen/my_profile/my_profile_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myPostStreamProvider);
    final users = ref.watch(myProfileViewModelProvider());
    final isSubscription = ref.watch(subscriptionProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppAppBar(),
        body: AsyncValueSwitcher(
          asyncValue: AsyncValueGroup.group2(state, isSubscription),
          onErrorTap: () {
            ref
              ..invalidate(myPostStreamProvider)
              ..invalidate(subscriptionProvider);
            ref.read(myProfileViewModelProvider().notifier).getData();
          },
          onData: (value) {
            return Column(
              children: [
                users.when(
                  data: (users, length, heartAmount) {
                    return AppHeader(
                      users: users,
                      length: length,
                      heartAmount: heartAmount,
                      isSubscription: value.$2,
                    );
                  },
                  loading: () {
                    return AppHeaderSkeleton();
                  },
                  error: SizedBox.shrink,
                ),
                const Gap(4),
                AppMyProfileButton(
                  onTapEdit: () {
                    context.pushNamed(RouterPath.edit).then((value) {
                      if (value != null) {
                        ref
                            .read(myProfileViewModelProvider().notifier)
                            .getData();
                      }
                    });
                  },
                  onTapExchange: () {
                    EasyDebounce.debounce(
                      'exchange point',
                      const Duration(seconds: 1),
                      () async {
                        SnackBarHelper().openComingSoonSnackBar(context);
                      },
                    );
                  },
                ),
                const Gap(8),
                Expanded(
                  child: AppListView(
                    data: value.$1,
                    routerPath: RouterPath.myProfileDetail,
                    refresh: () => ref.refresh(myPostStreamProvider),
                    isTimeLine: false,
                  ),
                ),
              ],
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
