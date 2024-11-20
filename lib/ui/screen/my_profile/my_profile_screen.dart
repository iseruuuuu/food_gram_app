import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/data/supabase/post_stream.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_app_bar.dart';
import 'package:food_gram_app/ui/component/app_calendar_view.dart';
import 'package:food_gram_app/ui/component/app_error_widget.dart';
import 'package:food_gram_app/ui/component/app_floating_button.dart';
import 'package:food_gram_app/ui/component/app_header.dart';
import 'package:food_gram_app/ui/component/app_list_view.dart';
import 'package:food_gram_app/ui/component/app_profile_button.dart';
import 'package:food_gram_app/ui/screen/my_profile/my_profile_view_model.dart';
import 'package:food_gram_app/utils/snack_bar_manager.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myPostStreamProvider);
    final users = ref.watch(myProfileViewModelProvider());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppAppBar(),
        body: users.when(
          data: (users, length, heartAmount) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: AppHeader(
                  users: users,
                  length: length,
                  heartAmount: heartAmount,
                ),
              ),
              SliverToBoxAdapter(child: Gap(4)),
              SliverToBoxAdapter(
                child: AppMyProfileButton(
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
                        openComingSoonSnackBar(context);
                      },
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(child: Gap(4)),
              SliverToBoxAdapter(
                child: TabBar(
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(width: 2),
                    insets: EdgeInsets.symmetric(horizontal: 110),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                  tabs: const [
                    Tab(icon: Icon(Icons.fastfood_outlined)),
                    Tab(icon: Icon(Icons.calendar_month_outlined)),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  children: [
                    state.when(
                      data: (data) {
                        return AppListView(
                          data: data,
                          routerPath: RouterPath.myProfileDetailPost,
                          refresh: () => ref.refresh(myPostStreamProvider),
                          isTimeLine: false,
                        );
                      },
                      error: (_, __) {
                        return AppErrorWidget(
                          onTap: () {
                            ref.invalidate(myPostStreamProvider);
                            ref
                                .read(myProfileViewModelProvider().notifier)
                                .getData();
                          },
                        );
                      },
                      loading: () {
                        return Center(
                          child: Assets.image.loading.image(
                            width: 100,
                            height: 100,
                          ),
                        );
                      },
                    ),
                    state.when(
                      data: (data) {
                        return AppCalendarView(
                          data: data,
                          refresh: () => ref.refresh(myPostStreamProvider),
                        );
                      },
                      error: (_, __) {
                        return AppErrorWidget(
                          onTap: () {
                            ref.invalidate(myPostStreamProvider);
                            ref
                                .read(myProfileViewModelProvider().notifier)
                                .getData();
                          },
                        );
                      },
                      loading: () {
                        return Center(
                          child: Assets.image.loading.image(
                            width: 100,
                            height: 100,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => Center(
            child: Assets.image.loading.image(width: 100, height: 100),
          ),
          error: () => AppErrorWidget(
            onTap: () => ref.refresh(myPostStreamProvider),
          ),
        ),
        floatingActionButton: AppFloatingButton(
          onTap: () {
            context.pushNamed(RouterPath.myProfilePost).then((value) {
              if (value != null) {
                ref.invalidate(myPostStreamProvider);
                ref.read(myProfileViewModelProvider().notifier).getData();
              }
            });
          },
        ),
      ),
    );
  }
}
