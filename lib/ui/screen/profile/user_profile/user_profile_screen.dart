import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/core/theme/style/profile_style.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_error_widget.dart';
import 'package:food_gram_app/ui/component/common/app_list_view.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/profile/app_profile_header.dart';
import 'package:food_gram_app/ui/screen/profile/user_profile/user_profile_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({
    required this.users,
    super.key,
  });

  final Users users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileViewModelProvider(users.userId));
    final posts = ref.watch(profileRepositoryProvider(userId: users.userId));
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: Text('@${users.userName}', style: ProfileStyle.userName()),
          leading: GestureDetector(
            onTap: context.pop,
            child: const Icon(Icons.close, size: 30),
          ),
        ),
        body: RefreshIndicator(
          color: Colors.black,
          onRefresh: () async {
            await Future<void>.delayed(const Duration(seconds: 1));
            ref.invalidate(profileRepositoryProvider(userId: users.userId));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: AppProfileHeader(
                  users: users,
                  length: posts.when(
                    data: (value) => value.length,
                    error: (_, __) => 0,
                    loading: () => 0,
                  ),
                  heartAmount: state.heartAmount,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 8),
                sliver: posts.when(
                  data: (value) {
                    return value.isNotEmpty
                        ? AppListView(
                            posts: value.map(Posts.fromJson).toList(),
                            routerPath: RouterPath.myProfileDetail,
                            type: AppListViewType.profile,
                            refresh: () => ref.refresh(myPostStreamProvider),
                          )
                        : const SliverToBoxAdapter(
                            child: AppEmpty(),
                          );
                  },
                  error: (_, __) => SliverToBoxAdapter(
                    child: AppErrorWidget(
                      onTap: () {
                        ref.invalidate(
                          profileRepositoryProvider(userId: users.userId),
                        );
                      },
                    ),
                  ),
                  loading: () => const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: AppContentLoading(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
