import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/data/supabase/service/posts_service.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';
import 'package:heroine/heroine.dart';

class StoryWidget extends ConsumerWidget {
  const StoryWidget({
    required this.data,
    super.key,
  });

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final randomIndexes = List<int>.generate(data.length, (index) => index)
      ..shuffle();
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: data.length,
      itemBuilder: (context, index) {
        final randomIndex = randomIndexes[index];
        return Heroine(
          tag: data[randomIndex]['id'],
          flightShuttleBuilder: SingleShuttleBuilder(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF00A5),
                    Color(0xFFFE0141),
                    Color(0xFFFF9F00),
                    Color(0xFFFFC900),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(3),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3),
                    child: GestureDetector(
                      onTap: () async {
                        final post = await ref
                            .read(postsServiceProvider)
                            .getPost(data, randomIndex);
                        await context.pushNamed(
                          RouterPath.storyPage,
                          extra: post,
                        );
                      },
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        foregroundImage: NetworkImage(
                          supabase.storage
                              .from('food')
                              .getPublicUrl(data[randomIndex]['food_image']),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
