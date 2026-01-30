import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:go_router/go_router.dart';

class AppShareModalSheet extends StatelessWidget {
  const AppShareModalSheet({
    required this.sharePost,
    required this.shareOnlyPost,
    super.key,
  });

  final VoidCallback sharePost;
  final VoidCallback shareOnlyPost;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3.5,
      child: DecoratedBox(
        decoration: const BoxDecoration(
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
                    sharePost();
                  },
                  child: Text(
                    Translations.of(context).share.textAndImage,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(),
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: TextButton(
                onPressed: () {
                  context.pop();
                  shareOnlyPost();
                },
                child: Text(
                  Translations.of(context).share.imageOnly,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            const Divider(),
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  Translations.of(context).close,
                  style: const TextStyle(
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
