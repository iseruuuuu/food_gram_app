import 'package:flutter/material.dart';
import 'package:food_gram_app/model/post.dart';
import 'package:food_gram_app/screen/detail/detail_post_screen.dart';

class AppListView extends StatelessWidget {
  const AppListView({
    required this.stream,
    super.key,
  });

  final Stream<List<Map<String, dynamic>>>? stream;

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
                onTap: () {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPostScreen(
                        post: post,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: MediaQuery.of(context).size.width / 3,
                  color: Colors.blue,
                  //TODO あとでNetworkImageに変更する
                  child: Image.asset(data[index]['food_image']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
