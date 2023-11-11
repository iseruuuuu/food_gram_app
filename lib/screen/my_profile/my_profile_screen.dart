import 'package:flutter/material.dart';
import 'package:food_gram_app/component/app_cell.dart';
import 'package:food_gram_app/screen/edit/edit_screen.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFEADDFF),
                      radius: 50,
                    ),
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '13',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '投稿',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  '井関竜太郎',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@isekiryu',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Text(
                  'YUMEMI Inc.のFlutter Engineer📱/立正大学院応用心理学専攻1年生/ Flutterと彼女が好きな文系大学院生 アプリを53個リリースしています🔥',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditScreen(),
                    ),
                  );
                },
                child: const Text('プロフィールを編集'),
              ),
              ElevatedButton(
                onPressed: () {
                  //TODO シェアする
                },
                child: const Text('プロフィールをシェア'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              itemCount: 15,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemBuilder: (context, index) {
                return const AppCell();
              },
            ),
          ),
        ],
      ),
    );
  }
}
