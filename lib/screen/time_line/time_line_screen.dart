import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/component/app_app_bar.dart';
import 'package:food_gram_app/component/app_floating_button.dart';
import 'package:food_gram_app/component/app_list_view.dart';
import 'package:food_gram_app/screen/post/post_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TimeLineScreen extends StatelessWidget {
  const TimeLineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream =
        Supabase.instance.client.from('posts').stream(primaryKey: ['id']);
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      appBar: AppAppBar(),
      body: Column(
        children: [
          AppListView(stream: stream),
        ],
      ),
      floatingActionButton: AppFloatingButton(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostScreen(),
            ),
          );
        },
      ),
    );
  }
}
