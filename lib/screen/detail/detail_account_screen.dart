import 'package:flutter/material.dart';
import 'package:food_gram_app/component/app_list_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetailAccountScreen extends StatelessWidget {
  const DetailAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //TODO　指定したIDから取得する
    final stream =
        Supabase.instance.client.from('posts').stream(primaryKey: ['id']);
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
          AppListView(stream: stream),
        ],
      ),
    );
  }
}
