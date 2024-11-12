import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPostImageModalSheet extends StatelessWidget {
  const AppPostImageModalSheet({
    required this.camera,
    required this.album,
    super.key,
  });

  final Function() camera;
  final Function() album;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: TextButton(
                  onPressed: () {
                    context.pop();
                    camera();
                  },
                  child: Text(
                    'カメラ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            Divider(),
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: TextButton(
                onPressed: () {
                  context.pop();
                  album();
                },
                child: Text(
                  'アルバム',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            Divider(),
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  '閉じる',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
