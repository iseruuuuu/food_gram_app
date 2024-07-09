import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/data/supabase/post_stream.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_app_bar.dart';
import 'package:food_gram_app/ui/component/app_error_widget.dart';
import 'package:food_gram_app/ui/component/app_floating_button.dart';
import 'package:food_gram_app/ui/component/app_header.dart';
import 'package:food_gram_app/ui/component/app_list_view.dart';
import 'package:food_gram_app/ui/component/app_place_list_view.dart';
import 'package:food_gram_app/ui/component/app_profile_button.dart';
import 'package:food_gram_app/ui/screen/my_profile/my_profile_view_model.dart';
import 'package:food_gram_app/utils/snack_bar_manager.dart';
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
          data: (name, userName, selfIntroduce, image, length) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppHeader(
                image: image,
                length: length,
                name: name,
                userName: userName,
                selfIntroduce: selfIntroduce,
              ),
              AppMyProfileButton(
                onTapEdit: () {
                  context.pushNamed(RouterPath.edit).then((value) {
                    if (value != null) {
                      ref.read(myProfileViewModelProvider().notifier).getData();
                    }
                  });
                },
                onTapExchange: () {
                  EasyDebounce.debounce('exchange point', Duration(seconds: 1),
                      () async {
                    openComingSoonSnackBar(context);
                  });
                },
              ),
              TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3),
                  insets: EdgeInsets.symmetric(horizontal: 110),
                ),
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                tabs: [
                  Tab(text: 'Food'),
                  Tab(text: 'Place'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    state.when(
                      data: (data) {
                        return AppListView(
                          data: data,
                          routerPath: RouterPath.myProfileDetailPost,
                          refresh: () => ref.refresh(myPostStreamProvider),
                        );
                      },
                      error: (_, __) {
                        return AppErrorWidget(
                          onTap: () {
                            ref.refresh(myPostStreamProvider);
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
                        return AppPlaceListView(
                          data: data,
                          refresh: () => ref.refresh(myPostStreamProvider),
                        );
                      },
                      error: (_, __) {
                        return AppErrorWidget(
                          onTap: () {
                            ref.refresh(myPostStreamProvider);
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
            child: Center(
              child: Assets.image.loading.image(
                width: 100,
                height: 100,
              ),
            ),
          ),
          error: () => AppErrorWidget(
            onTap: () => ref.refresh(myPostStreamProvider),
          ),
        ),
        floatingActionButton: AppFloatingButton(
          onTap: () {
            context.pushNamed(RouterPath.myProfilePost).then((value) {
              if (value != null) {
                ref.refresh(myPostStreamProvider);
                ref.read(myProfileViewModelProvider().notifier).getData();
              }
            });
          },
        ),
      ),
    );
  }
}
