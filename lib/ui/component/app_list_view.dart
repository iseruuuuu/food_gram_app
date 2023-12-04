import 'package:flutter/material.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/model/model.dart';
import 'package:food_gram_app/model/posts.dart';
import 'package:food_gram_app/model/users.dart';
import 'package:go_router/go_router.dart';

class AppListView extends StatelessWidget {
  const AppListView({
    required this.stream,
    required this.routerPath,
    super.key,
  });

  final Stream<List<Map<String, dynamic>>>? stream;
  final String routerPath;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final data = snapshot.data!;
          return GridView.builder(
            itemCount: data.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  final posts = Posts(
                    id: int.parse(data[index]['id'].toString()),
                    userId: data[index]['user_id'],
                    foodImage: data[index]['food_image'],
                    foodName: data[index]['food_name'],
                    restaurant: data[index]['restaurant'],
                    comment: data[index]['comment'],
                    createdAt: DateTime.parse(data[index]['created_at']),
                    lat: double.parse(data[index]['lat'].toString()),
                    lng: double.parse(data[index]['lng'].toString()),
                    heart: int.parse(data[index]['heart'].toString()),
                  );
                  final dynamic postUserId = await supabase
                      .from('users')
                      .select()
                      .eq('user_id', data[index]['user_id'])
                      .single();
                  final users = Users(
                    id: postUserId['id'],
                    userId: postUserId['user_id'],
                    name: postUserId['name'],
                    userName: postUserId['user_name'],
                    selfIntroduce: postUserId['self_introduce'],
                    image: postUserId['image'],
                    createdAt: DateTime.parse(postUserId['created_at']),
                    updateTime: DateTime.parse(postUserId['updated_at']),
                  );
                  await context.pushNamed(
                    routerPath,
                    extra: Model(users, posts),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.width / 3,
                  color: Colors.blue,
                  child: Image.network(
                    supabase.storage
                        .from('food')
                        .getPublicUrl(data[index]['food_image']),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
