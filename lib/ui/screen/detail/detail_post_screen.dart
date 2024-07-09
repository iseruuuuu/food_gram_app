import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/component/app_heart.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/dialog/app_share_dialog.dart';
import 'package:food_gram_app/ui/screen/detail/component/detail_post_bottom_sheet.dart';
import 'package:food_gram_app/utils/mixin/show_modal_bottom_sheet_mixin.dart';
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
    with ShowModalBottomSheetMixin, TickerProviderStateMixin {
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
              DetailPostBottomSheet(
                posts: widget.posts,
                users: widget.users,
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
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '@${widget.users.userName}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Assets.gif.profileDetail.image(width: 60, height: 60),
                        Gap(10),
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
                              barrierDismissible: true,
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
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          '$initialHeart ${L10n.of(context).post_detail_heart}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      widget.posts.foodName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
