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
        data: (value) {
          final posted = _postedTagIds(value);
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
          final columns = tagDexCrossAxisCount(
            MediaQuery.sizeOf(context).width,
          );
          final progress = total == 0 ? 0.0 : collected / total;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
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
                        t.hint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (final entry in categories) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            getLocalizedCategoryName(entry.key, context),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimaryOf(context),
                            ),
                          ),
                        ),
                        Text(
                          '${_collectedCount(entry.value, posted)} / ${entry.value.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      final tagId = entry.value[index];
                      final isOn = posted.contains(tagId);
                      final name = getLocalizedFoodName(tagId, context);
                      Widget icon = FoodTagIcon(tagId: tagId, size: 32);
                      if (!isOn) {
                        icon = Opacity(
                          opacity: 0.4,
                          child: icon,
                        );
                      }
                      final offColor = AppTheme.textSecondaryOf(context)
                          .withValues(alpha: 0.4);
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
                              color: isOn
                                  ? AppTheme.primaryOrange
                                  : AppTheme.dividerOf(context),
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
                                          fontWeight: isOn
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isOn
                                              ? AppTheme.textPrimaryOf(context)
                                              : AppTheme.textSecondaryOf(
                                                  context,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: ExcludeSemantics(
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isOn
                                          ? AppTheme.primaryOrange
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isOn
                                            ? AppTheme.primaryOrange
                                            : offColor,
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              SliverToBoxAdapter(child: Gap(bottom)),
            ],
          );
        },
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

/// 狭い画面では 3 列にする。
///
/// 幅 320px では左右 padding を除いて 288px。4 列だとタイル幅が約 66px になり、
/// 「その他のご飯」のような名前が 2 行でも切れる。高さを伸ばすだけでは幅が足りない。
@visibleForTesting
int tagDexCrossAxisCount(double viewportWidth) {
  if (viewportWidth < 360) {
    return 3;
  }
  return 4;
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
