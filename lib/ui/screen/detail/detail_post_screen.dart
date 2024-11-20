import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/component/app_heart.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/dialog/app_share_dialog.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_master_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_my_info_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_other_info_modal_sheet.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:gap/gap.dart';
import 'package:gif/gif.dart';

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
    with TickerProviderStateMixin {
  bool isHeart = false;
  bool doesHeart = false;
  int initialHeart = 0;
  late GifController controller;

  @override
  void initState() {
    initialHeart = widget.posts.heart;
    controller = GifController(vsync: this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    initialHeart = widget.posts.heart;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final user = supabase.auth.currentUser?.id;
    final loading = ref.watch(loadingProvider);
    return PopScope(
      canPop: !loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: !loading,
          surfaceTintColor: Colors.transparent,
          actions: [
            if (!loading)
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      if (user == Env.masterAccount) {
                        return AppDetailMasterModalSheet(
                          posts: widget.posts,
                          users: widget.users,
                        );
                      }
                      if (widget.users.userId != user) {
                        return AppDetailOtherInfoModalSheet(
                          users: widget.users,
                          posts: widget.posts,
                        );
                      } else {
                        return AppDetailMyInfoModalSheet(
                          users: widget.users,
                          posts: widget.posts,
                        );
                      }
                    },
                  );
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
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
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width - 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.users.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '@${widget.users.userName}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
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
                                doesHeart = false;
                              });
                            } else {
                              await supabase.from('posts').update({
                                'heart': widget.posts.heart + 1,
                              }).match({'id': widget.posts.id});
                              setState(() {
                                initialHeart++;
                                isHeart = true;
                                doesHeart = true;
                              });
                            }
                          }
                        : null,
                    child: Container(
                      width: deviceWidth,
                      height: deviceWidth,
                      color: Colors.white,
                      child: CachedNetworkImage(
                        imageUrl: supabase.storage
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
                                    doesHeart = false;
                                  });
                                } else {
                                  await supabase.from('posts').update({
                                    'heart': widget.posts.heart + 1,
                                  }).match({'id': widget.posts.id});
                                  setState(() {
                                    initialHeart++;
                                    isHeart = true;
                                    doesHeart = true;
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
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          EasyDebounce.debounce(
                              'post', Duration(milliseconds: 200), () async {
                            await showDialog(
                              context: context,
                              useSafeArea: false,
                              builder: (context) {
                                return AppShareDialog(
                                  posts: widget.posts,
                                  users: widget.users,
                                );
                              },
                            );
                          });
                        },
                        child: Icon(
                          Icons.send,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          '$initialHeart'
                          ' ${L10n.of(context).postDetailLikeButton}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Text(
                      widget.posts.foodName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'In ${widget.posts.restaurant}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Gap(10),
                  Wrap(
                    spacing: 10,
                    children: [
                      Gap(10),
                      if (widget.posts.foodTag != '')
                        Chip(
                          backgroundColor: Colors.white,
                          label: Text(widget.posts.foodTag),
                          labelStyle: TextStyle(fontSize: 20),
                        ),
                      Gap(10),
                      if (widget.posts.restaurantTag != '')
                        Chip(
                          backgroundColor: Colors.white,
                          label: Text(widget.posts.restaurantTag),
                          labelStyle: TextStyle(fontSize: 20),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      widget.posts.comment,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppHeart(
              isHeart: doesHeart,
              controller: controller,
            ),
            AppLoading(
              loading: loading,
              status: 'Loading...',
            ),
          ],
        ),
      ),
    );
  }
}
