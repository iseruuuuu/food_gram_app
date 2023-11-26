import 'package:flutter/material.dart';
import 'package:food_gram_app/model/post.dart';
import 'package:food_gram_app/screen/detail/detail_post_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppListView extends StatelessWidget {
  const AppListView({
    required this.stream,
    super.key,
  });

  final Stream<List<Map<String, dynamic>>>? stream;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client.storage;
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
                  final post = Post(
                    id: int.parse(data[index]['id'].toString()),
                    foodImage: data[index]['food_image'],
                    foodName: data[index]['food_name'],
                    restaurant: data[index]['restaurant'],
                    comment: data[index]['comment'],
                    createdAt: DateTime.parse(data[index]['created_at']),
                    lat: double.parse(data[index]['lat'].toString()),
                    lng: double.parse(data[index]['lng'].toString()),
                    heart: int.parse(data[index]['heart'].toString()),
                  );
                  final supabase = Supabase.instance.client;
                  final dynamic postUserId = await supabase
                      .from('users')
                      .select()
                      .eq('user_id', data[index]['user_id'])
                      .single();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPostScreen(
                        post: post,
                        name: postUserId['name'],
                        image: postUserId['image'],
                        userName: postUserId['user_name'],
                        userId: postUserId['user_id'],
                        id: data[index]['id'],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.width / 3,
                  color: Colors.blue,
                  child: Image.network(
                    supabase
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
