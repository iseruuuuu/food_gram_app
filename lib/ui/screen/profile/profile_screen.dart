import 'package:flutter/material.dart';
import 'package:food_gram_app/core/data/supabase/post_stream.dart';
import 'package:food_gram_app/core/data/supabase/service/posts_service.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/utils/async_value_group.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_header.dart';
import 'package:food_gram_app/ui/component/app_list_view.dart';
import 'package:food_gram_app/ui/screen/profile/provider/profile_provider.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    required this.users,
    super.key,
  });

  final Users users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProviderProvider(users.userId));
    final posts =
        ref.watch(postsFromUserProviderProvider(userId: users.userId));
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: context.pop,
            child: Icon(Icons.close, size: 30),
          ),
        ),
        body: Column(
          children: [
            AppHeader(
              users: users,
              length: state.length,
              heartAmount: state.heartAmount,
              isSubscription: users.isSubscribe,
            ),
            const Gap(4),
            Expanded(
              child: AsyncValueSwitcher(
                asyncValue: posts,
                onErrorTap: () {
                  ref.invalidate(
                      postsFromUserProviderProvider(userId: users.userId));
                },
                onData: (value) {
                  return AppListView(
                    data: value,
                    routerPath: RouterPath.myProfileDetail,
                    refresh: () => ref.refresh(myPostStreamProvider),
                    isTimeLine: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
