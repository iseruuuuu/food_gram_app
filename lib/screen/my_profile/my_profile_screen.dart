import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/component/app_app_bar.dart';
import 'package:food_gram_app/component/app_error_widget.dart';
import 'package:food_gram_app/component/app_floating_button.dart';
import 'package:food_gram_app/component/app_header.dart';
import 'package:food_gram_app/component/app_list_view.dart';
import 'package:food_gram_app/component/app_profile_button.dart';
import 'package:food_gram_app/screen/edit/edit_screen.dart';
import 'package:food_gram_app/screen/my_profile/my_profile_view_model.dart';
import 'package:food_gram_app/screen/post/post_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myProfileViewModelProvider());
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser?.id;
    final stream =
        supabase.from('posts').stream(primaryKey: ['id']).eq('user_id', user);
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      appBar: AppAppBar(),
      body: state.when(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditScreen(),
                  ),
                ).then((_) {
                  ref.read(myProfileViewModelProvider().notifier).getData();
                });
              },
              onTapShare: () {
                //TODO シェアする
              },
            ),
            const SizedBox(height: 10),
            AppListView(stream: stream),
          ],
        ),
        loading: () => Center(
          child: Image.asset(
            'assets/loading/loading.gif',
            width: 100,
            height: 100,
          ),
        ),
        error: () => AppErrorWidget(
          onTap: ref.read(myProfileViewModelProvider().notifier).getData,
        ),
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
