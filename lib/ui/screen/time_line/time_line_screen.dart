import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/config/supabase/post_stream.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_app_bar.dart';
import 'package:food_gram_app/ui/component/app_error_widget.dart';
import 'package:food_gram_app/ui/component/app_floating_button.dart';
import 'package:food_gram_app/ui/component/app_list_view.dart';
import 'package:go_router/go_router.dart';

class TimeLineScreen extends ConsumerWidget {
  const TimeLineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postStreamProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(),
      body: state.when(
        data: (data) {
          return AppListView(
            data: data,
            routerPath: RouterPath.timeLineDeitailPost,
            refresh: () => ref.refresh(postStreamProvider),
          );
        },
        error: (_, __) {
          return AppErrorWidget(
            onTap: () => ref.refresh(postStreamProvider),
          );
        },
        loading: () {
          return Center(
            child: Image.asset(
              'assets/loading/loading.gif',
              width: 100,
              height: 100,
            ),
          );
        },
      ),
      floatingActionButton: AppFloatingButton(
        onTap: () async {
          await context.pushNamed(RouterPath.timeLinepost).then((value) async {
            if (value != null) {
              ref.refresh(postStreamProvider);
            }
          });
        },
      ),
    );
  }
}
