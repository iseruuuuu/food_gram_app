import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/theme/style/profile_style.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/food_tag_icon.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 自分の投稿に使ったタグだけをオンにした図鑑。
class TagDexScreen extends ConsumerWidget {
  const TagDexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context).tagDex;
    final posts = ref.watch(myPostStreamProvider);
    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundOf(context),
        surfaceTintColor: AppTheme.backgroundOf(context),
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.title,
          style: ProfileStyle.screenTitle(context),
        ),
      ),
      body: posts.when(
        data: (value) => _TagDexBody(posts: value),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryOrange,
          ),
        ),
        error: (_, __) => Center(
          child: TextButton(
            onPressed: () => ref.invalidate(myPostStreamProvider),
            child: Text(t.retry),
          ),
        ),
      ),
    );
  }
}

class _TagDexBody extends StatelessWidget {
  const _TagDexBody({required this.posts});

  final List<Posts> posts;

  @override
  Widget build(BuildContext context) {
    final posted = _postedTagIds(posts);
    final categories = foodCategory.entries.toList();
    final total = categories.fold<int>(
      0,
      (sum, entry) => sum + entry.value.length,
    );
    final collected = categories.fold<int>(
      0,
      (sum, entry) => sum + _collectedCount(entry.value, posted),
    );
    final bottom = MediaQuery.paddingOf(context).bottom + 24;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _TagDexHeader(
            collected: collected,
            total: total,
          ),
        ),
        for (final entry in categories) ...[
          SliverToBoxAdapter(
            child: _CategoryHeader(
              name: getLocalizedCategoryName(entry.key, context),
              collected: _collectedCount(entry.value, posted),
              total: entry.value.length,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.72,
              ),
              itemCount: entry.value.length,
              itemBuilder: (context, index) {
                final tagId = entry.value[index];
                return _TagDexTile(
                  tagId: tagId,
                  isOn: posted.contains(tagId),
                );
              },
            ),
          ),
        ],
        SliverToBoxAdapter(child: Gap(bottom)),
      ],
    );
  }
}

class _TagDexHeader extends StatelessWidget {
  const _TagDexHeader({
    required this.collected,
    required this.total,
  });

  final int collected;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : collected / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        children: [
          Text(
            '$collected / $total',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimaryOf(context),
            ),
          ),
          const Gap(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppTheme.orangeBackgroundOf(context),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryOrange,
              ),
            ),
          ),
          const Gap(8),
          Text(
            Translations.of(context).tagDex.hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.name,
    required this.collected,
    required this.total,
  });

  final String name;
  final int collected;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryOf(context),
              ),
            ),
          ),
          Text(
            '$collected / $total',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagDexTile extends StatelessWidget {
  const _TagDexTile({
    required this.tagId,
    required this.isOn,
  });

  final String tagId;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    final name = getLocalizedFoodName(tagId, context);
    Widget icon = FoodTagIcon(tagId: tagId, size: 32);
    if (!isOn) {
      icon = Opacity(
        opacity: 0.4,
        child: icon,
      );
    }
    return Semantics(
      label: name,
      selected: isOn,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isOn
              ? AppTheme.orangeBackgroundOf(context)
              : AppTheme.cardOf(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOn ? AppTheme.primaryOrange : AppTheme.dividerOf(context),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
              child: Column(
                children: [
                  icon,
                  const Gap(4),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        height: 1.15,
                        fontWeight: isOn ? FontWeight.w700 : FontWeight.w500,
                        color: isOn
                            ? AppTheme.textPrimaryOf(context)
                            : AppTheme.textSecondaryOf(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: _StatusLamp(isOn: isOn),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLamp extends StatelessWidget {
  const _StatusLamp({required this.isOn});

  final bool isOn;

  @override
  Widget build(BuildContext context) {
    final offColor = AppTheme.textSecondaryOf(context).withValues(alpha: 0.4);
    return ExcludeSemantics(
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOn ? AppTheme.primaryOrange : Colors.transparent,
          border: Border.all(
            color: isOn ? AppTheme.primaryOrange : offColor,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

Set<String> _postedTagIds(List<Posts> posts) {
  final ids = <String>{};
  for (final post in posts) {
    ids.addAll(parseFoodTagIds(post.foodTag));
  }
  return ids;
}

int _collectedCount(List<String> tagIds, Set<String> posted) {
  var count = 0;
  for (final id in tagIds) {
    if (posted.contains(id)) {
      count++;
    }
  }
  return count;
}
