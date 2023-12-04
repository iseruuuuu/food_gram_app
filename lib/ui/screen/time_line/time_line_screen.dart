import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_app_bar.dart';
import 'package:food_gram_app/ui/component/app_floating_button.dart';
import 'package:food_gram_app/ui/component/app_list_view.dart';
import 'package:go_router/go_router.dart';

class TimeLineScreen extends StatelessWidget {
  const TimeLineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = supabase.from('posts').stream(primaryKey: ['id']);
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      appBar: AppAppBar(),
      body: Column(
        children: [
          AppListView(
            stream: stream,
            routerPath: RouterPath.timeLineDeitailPost,
          ),
        ],
      ),
      floatingActionButton: AppFloatingButton(
        onTap: () async {
          await context.pushNamed(RouterPath.timeLinepost).then((value) async {
            if (value != null) {
              //TODO データが更新されたら、更新をする
            }
          });
        },
      ),
    );
  }
}
