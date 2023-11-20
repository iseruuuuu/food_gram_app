import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/component/app_list_view.dart';
import 'package:food_gram_app/screen/edit/edit_screen.dart';
import 'package:food_gram_app/screen/my_profile/my_profile_view_model.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage(state.image),
                      radius: 50,
                    ),
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          //TODO 投稿数を取得する
                          '13',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '投稿',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  state.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@${state.userName}',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Text(
                  state.selfIntroduce,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditScreen(),
                    ),
                  ).then((_) {
                    ref
                        .read(myProfileViewModelProvider().notifier)
                        .getProfile();
                  });
                },
                child: const Text('プロフィールを編集'),
              ),
              ElevatedButton(
                onPressed: () {
                  //TODO シェアする
                },
                child: const Text('プロフィールをシェア'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppListView(stream: stream),
        ],
      ),
    );
  }
}
