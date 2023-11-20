import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/model/post.dart';
import 'package:food_gram_app/screen/detail/detail_account_screen.dart';

class DetailPostScreen extends StatelessWidget {
  const DetailPostScreen({
    required this.post,
    super.key,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: deviceWidth,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailAccountScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircleAvatar(),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '井関竜太郎',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@Isekiryu',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.menu),
                ),
              ],
            ),
          ),
          Container(
            width: deviceWidth,
            height: deviceWidth,
            color: Colors.blue,
            child: Image.asset(post.foodImage),
          ),
          Row(
            children: [
              SizedBox(width: 5),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  CupertinoIcons.heart,
                  size: 30,
                ),
              ),
              IconButton(
                onPressed: () {},
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
