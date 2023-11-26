import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/mixin/dialog_mixin.dart';
import 'package:food_gram_app/mixin/url_launcher_mixin.dart';
import 'package:food_gram_app/model/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailPostScreen extends ConsumerWidget
    with UrlLauncherMixin, DialogMixin {
  const DetailPostScreen({
    required this.post,
    required this.name,
    required this.image,
    required this.userName,
    required this.userId,
    required this.id,
    super.key,
  });

  final Post post;
  final String name;
  final String image;
  final String userName;
  final String userId;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client.storage;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      appBar: AppBar(
        backgroundColor: CupertinoColors.extraLightBackgroundGray,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: deviceWidth,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Image.asset(image),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@$userName',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  onPressed: () async {
                    final supabase = Supabase.instance.client;
                    final user = supabase.auth.currentUser?.id;
                    if (userId == user) {
                      openDeleteDialog(
                        context: context,
                        delete: () async {
                          await supabase.from('posts').delete().eq('id', id);
                          Navigator.pop(context);
                        },
                      );
                    } else {
                      openReportDialog(
                        context: context,
                        openUrl: () async {
                          await launcherUrl(
                            'https://docs.google.com/forms/d/1uDNHpaPTNPK7tBjbfNW87ykYH3JZO0D2l10oBtVxaQA/edit',
                            context,
                          );
                        },
                      );
                    }
                  },
                  icon: Icon(Icons.menu),
                ),
              ],
            ),
          ),
          Container(
            width: deviceWidth,
            height: deviceWidth,
            color: Colors.blue,
            child: Image.network(
              supabase.from('food').getPublicUrl(post.foodImage),
              fit: BoxFit.cover,
            ),
          ),
          Row(
            children: [
              SizedBox(width: 5),
              IconButton(
                onPressed: () {
                  //TODO いいね機能を実装する
                },
                icon: Icon(
                  CupertinoIcons.heart,
                  size: 30,
                ),
              ),
              IconButton(
                onPressed: () {
                  //TODO 共有機能を実装する
                },
                icon: Icon(
                  Icons.send,
                  size: 30,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              '${post.heart}いいね',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              'In ${post.restaurant}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              post.comment,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
