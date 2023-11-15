import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/screen/detail/detail_account_screen.dart';

class DetailPostScreen extends StatelessWidget {
  const DetailPostScreen({super.key});

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
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(CupertinoIcons.heart),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.send),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              '感想\n'
              'aaaaaaaaaaaaaaaaaaa\n'
              'aaaaaaaaaaaaaaaaaaa\n'
              'aaaaaaaaaaaaaaaaaaa\n',
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
