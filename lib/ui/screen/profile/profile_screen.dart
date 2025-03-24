import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/post_repository.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_empty.dart';
import 'package:food_gram_app/ui/component/app_error_widget.dart';
import 'package:food_gram_app/ui/component/app_header.dart';
import 'package:food_gram_app/ui/component/app_list_view.dart';
import 'package:food_gram_app/ui/screen/profile/profile_view_model.dart';
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
    final state = ref.watch(profileViewModelProvider(users.userId));
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                users.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                '@${users.userName}',
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          leading: GestureDetector(
            onTap: context.pop,
            child: const Icon(Icons.close, size: 30),
          ),
        ),
        body: RefreshIndicator(
          color: Colors.black,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            ref.invalidate(profileRepositoryProvider(userId: users.userId));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: AppHeader(
                  users: users,
                  length: state.length,
                  heartAmount: state.heartAmount,
                  isSubscription: users.isSubscribe,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 8),
                sliver: posts.when(
                  data: (value) {
                    return value.isNotEmpty
                        ? AppListView(
                            data: value,
                            routerPath: RouterPath.myProfileDetail,
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
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
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
