import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/mixin/dialog_mixin.dart';
import 'package:food_gram_app/mixin/url_launcher_mixin.dart';
import 'package:food_gram_app/model/post.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailPostScreen extends StatefulWidget
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
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  bool isHeart = false;
  int initialHeart = 0;

  @override
  void initState() {
    initialHeart = widget.post.heart;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    initialHeart = widget.post.heart;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final storage = Supabase.instance.client.storage;
    final supabase = Supabase.instance.client;
    final deviceWidth = MediaQuery.of(context).size.width;
    final user = supabase.auth.currentUser?.id;
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
                    child: Image.asset(widget.image),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${widget.userName}',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  onPressed: () async {
                    if (widget.userId == user) {
                      widget.openDeleteDialog(
                        context: context,
                        delete: () async {
                          await supabase
                              .from('posts')
                              .delete()
                              .eq('id', widget.id);
                          Navigator.pop(context);
                        },
                      );
                    } else {
                      widget.openReportDialog(
                        context: context,
                        openUrl: () async {
                          await widget.launcherUrl(
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
          GestureDetector(
            onDoubleTap: (widget.userId != user)
                ? () async {
                    if (isHeart) {
                      await supabase.from('posts').update({
                        'heart': widget.post.heart - 1,
                      }).match({'id': widget.post.id});
                      print(widget.post.heart);
                      setState(() {
                        initialHeart--;
                        isHeart = false;
                      });
                    } else {
                      await supabase.from('posts').update({
                        'heart': widget.post.heart + 1,
                      }).match({'id': widget.post.id});
                      print(widget.post.heart + 1);
                      setState(() {
                        initialHeart++;
                        isHeart = true;
                      });
                    }
                  }
                : null,
            child: Container(
              width: deviceWidth,
              height: deviceWidth,
              color: Colors.blue,
              child: Image.network(
                storage.from('food').getPublicUrl(widget.post.foodImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Row(
            children: [
              SizedBox(width: 5),
              IconButton(
                onPressed: (widget.userId != user)
                    ? () async {
                        if (isHeart) {
                          await supabase.from('posts').update({
                            'heart': widget.post.heart - 1,
                          }).match({'id': widget.post.id});
                          print(widget.post.heart);
                          setState(() {
                            initialHeart--;
                            isHeart = false;
                          });
                        } else {
                          await supabase.from('posts').update({
                            'heart': widget.post.heart + 1,
                          }).match({'id': widget.post.id});
                          print(widget.post.heart + 1);
                          setState(() {
                            initialHeart++;
                            isHeart = true;
                          });
                        }
                      }
                    : null,
                icon: Icon(
                  (isHeart || widget.userId == user)
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  color: isHeart ? Colors.red : Colors.black,
                  size: 30,
                ),
              ),
              IconButton(
                onPressed: () {
                  Share.share(
                    '${widget.post.restaurant}で食べたレビューを投稿しました！'
                    '\n詳しくはfoodGramで確認してみよう！'
                    '\n#foodGram',
                  );
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
              '$initialHeart いいね',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              'In ${widget.post.restaurant}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              widget.post.comment,
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
