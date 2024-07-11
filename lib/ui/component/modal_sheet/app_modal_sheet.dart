import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/main.dart';

class RestaurantInfoModal extends StatelessWidget {
  const RestaurantInfoModal({
    required this.post,
    super.key,
  });

  final List<Posts?> post;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: deviceWidth,
        height: deviceWidth / 1.8,
        child: ListView.builder(
          itemCount: post.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                child: Container(
                  width: deviceWidth / 1.1,
                  height: deviceHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: deviceWidth,
                        height: deviceWidth / 2.7,
                        child: CachedNetworkImage(
                          imageUrl: supabase.storage
                              .from('food')
                              .getPublicUrl(post[index]!.foodImage),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      Spacer(),
                      Material(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(post[index]!.restaurant),
                          titleTextStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          subtitle: Text(post[index]!.foodName),
                          subtitleTextStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AppImageModalSheet extends StatelessWidget {
  const AppImageModalSheet({
    required this.camera,
    required this.album,
    super.key,
  });

  final Function() camera;
  final Function() album;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: TextButton(
                  onPressed: () {
                    context.pop();
                    camera();
                  },
                  child: Text(
                    'カメラ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            Divider(),
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: TextButton(
                onPressed: () {
                  context.pop();
                  album();
                },
                child: Text(
                  'アルバム',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            Divider(),
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  '閉じる',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
