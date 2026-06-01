import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/share/post_share_template.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostShareTemplateSelectionView extends HookConsumerWidget {
  const PostShareTemplateSelectionView({
    required this.posts,
    required this.onTemplateSelected,
    required this.onClose,
    super.key,
  });

  final Posts posts;
  final ValueChanged<PostShareTemplateId> onTemplateSelected;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final templates = postShareTemplates;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: onClose,
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorScheme.onSurface,
          ),
        ),
        title: Text(
          t.share.chooseTemplate,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return _TemplateGridItem(
                  template: template,
                  posts: posts,
                  ref: ref,
                  onTap: () => onTemplateSelected(template.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateGridItem extends StatelessWidget {
  const _TemplateGridItem({
    required this.template,
    required this.posts,
    required this.ref,
    required this.onTap,
  });

  final PostShareTemplateDefinition template;
  final Posts posts;
  final WidgetRef ref;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final aspectRatio = template.size.width / template.size.height;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: FittedBox(
                        child: template.builder(posts, ref, t),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Gap(8),
          Text(
            template.name(t),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            template.description(t),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.65),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
