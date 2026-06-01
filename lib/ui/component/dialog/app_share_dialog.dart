import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/ui/component/share/post_share_preview_view.dart';
import 'package:food_gram_app/ui/component/share/post_share_template.dart';
import 'package:food_gram_app/ui/component/share/post_share_template_selection_view.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppShareDialog extends HookConsumerWidget {
  const AppShareDialog({
    required this.posts,
    required this.users,
    super.key,
  });

  final Posts posts;
  final Users users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTemplate = useState<PostShareTemplateId?>(null);

    if (selectedTemplate.value == null) {
      return PostShareTemplateSelectionView(
        posts: posts,
        onTemplateSelected: (templateId) {
          selectedTemplate.value = templateId;
        },
        onClose: context.pop,
      );
    }

    return PostSharePreviewView(
      posts: posts,
      users: users,
      templateId: selectedTemplate.value!,
      onBack: () {
        selectedTemplate.value = null;
      },
    );
  }
}
