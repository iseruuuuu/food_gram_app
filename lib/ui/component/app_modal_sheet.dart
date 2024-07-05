import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/main.dart';

class RestaurantInfoModal extends StatelessWidget {
  const RestaurantInfoModal({
    required this.post,
    super.key,
  });

  final Posts post;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: deviceWidth,
      height: deviceWidth / 1.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: deviceWidth,
            height: deviceWidth / 2.5,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: CachedNetworkImage(
                imageUrl:
                    supabase.storage.from('food').getPublicUrl(post.foodImage),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Spacer(),
          ListTile(
            title: Text(post.restaurant),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            subtitle: Text(post.foodName),
            subtitleTextStyle: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
