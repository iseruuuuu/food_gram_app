import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/model/posts.dart';
import 'package:food_gram_app/model/users.dart';
import 'package:food_gram_app/ui/screen/detail/detail_post_view_model.dart';
import 'package:food_gram_app/utils/mixin/dialog_mixin.dart';
import 'package:food_gram_app/utils/mixin/snack_bar_mixin.dart';
import 'package:food_gram_app/utils/mixin/url_launcher_mixin.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class DetailPostScreen extends ConsumerStatefulWidget {
  const DetailPostScreen({
    required this.posts,
    required this.users,
    super.key,
  });

  final Posts posts;
  final Users users;

  @override
  DetailPostScreenState createState() => DetailPostScreenState();
}

class DetailPostScreenState extends ConsumerState<DetailPostScreen>
    with DialogMixin, UrlLauncherMixin, SnackBarMixin {
  bool isHeart = false;
  int initialHeart = 0;

  @override
  void initState() {
    initialHeart = widget.posts.heart;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    initialHeart = widget.posts.heart;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final user = supabase.auth.currentUser?.id;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
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
                      child: Image.asset(widget.users.image),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.users.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${widget.users.userName}',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      (widget.users.userId == user)
                          ? openDialog(
                              context: context,
                              title: '投稿の削除',
                              subTitle: 'この投稿を削除しますか？\n一度削除してしまうと復元できません',
                              onTap: () async {
                                await ref
                                    .read(
                                      detailPostViewModelProvider().notifier,
                                    )
                                    .delete(widget.posts.id)
                                    .then((value) async {
                                  if (value) {
                                    openSnackBar(context, '削除が成功しました');
                                    await Future.delayed(Duration(seconds: 2));
                                    context.pop(true);
                                  } else {
                                    openSnackBar(context, '削除が失敗しました');
                                  }
                                });
                              },
                            )
                          : openDialog(
                              context: context,
                              title: '投稿の報告',
                              subTitle: 'この投稿について報告を行います。\n Googleフォームに遷移します。',
                              onTap: () async {
                                await launcherUrl(
                                  'https://docs.google.com/forms/d/1uDNHpaPTNPK7tBjbfNW87ykYH3JZO0D2l10oBtVxaQA/edit',
                                ).then((value) {
                                  if (!value) {
                                    openErrorSnackBar(context);
                                  } else {
                                    context.pop();
                                  }
                                });
                              },
                            );
                    },
                    icon: Icon(Icons.menu),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onDoubleTap: (widget.users.userId != user)
                  ? () async {
                      if (isHeart) {
                        await supabase.from('posts').update({
                          'heart': widget.posts.heart - 1,
                        }).match({'id': widget.posts.id});
                        setState(() {
                          initialHeart--;
                          isHeart = false;
                        });
                      } else {
                        await supabase.from('posts').update({
                          'heart': widget.posts.heart + 1,
                        }).match({'id': widget.posts.id});
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
                  supabase.storage
                      .from('food')
                      .getPublicUrl(widget.posts.foodImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 5),
                IconButton(
                  onPressed: (widget.users.userId != user)
                      ? () async {
                          if (isHeart) {
                            await supabase.from('posts').update({
                              'heart': widget.posts.heart - 1,
                            }).match({'id': widget.posts.id});
                            setState(() {
                              initialHeart--;
                              isHeart = false;
                            });
                          } else {
                            await supabase.from('posts').update({
                              'heart': widget.posts.heart + 1,
                            }).match({'id': widget.posts.id});
                            setState(() {
                              initialHeart++;
                              isHeart = true;
                            });
                          }
                        }
                      : null,
                  icon: Icon(
                    (isHeart || widget.users.userName == user)
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    color: isHeart ? Colors.red : Colors.black,
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Share.share(
                      '${widget.posts.restaurant}で食べたレビューを投稿しました！'
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
                'In ${widget.posts.restaurant}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                widget.posts.comment,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
