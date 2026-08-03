import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/stored_post_body.dart';
import 'package:go_router/go_router.dart';

class StoredPostScreen extends StatelessWidget {
  const StoredPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surface,
        title: Text(
          Translations.of(context).stored.savedPosts,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: const StoredPostBody(),
    );
  }
}
