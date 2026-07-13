import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// 記録タブ：今日の思い出セクション
class RecordTodayMemoriesSection extends StatelessWidget {
  const RecordTodayMemoriesSection({
    required this.posts,
    super.key,
  });

  final List<Posts> posts;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF161616) : Colors.white;
    final todayPost = recordTodayLatestPost(posts);
    final pastMemories = collectPastMemories(posts);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const Gap(6),
              Text(
                t.myMapRecord.todayMemoriesTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const Gap(14),
          if (todayPost != null)
            _TodayHeroCard(post: todayPost)
          else
            const _NoTodayCard(),
          const Gap(16),
          Text(
            t.myMapRecord.pastMemoriesLabel,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(10),
          _MemoryCarousel(memories: pastMemories),
        ],
      ),
    );
  }
}

/// 今日の最新投稿を大きく見せるヒーローカード
class _TodayHeroCard extends ConsumerWidget {
  const _TodayHeroCard({required this.post});

  final Posts post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateText = DateFormat('yyyy/M/d', localeTag).format(post.createdAt);
    final area = recordPostAreaLabel(post);
    final storageKey = post.firstFoodImage;
    final imageUrl = storageKey.isEmpty
        ? null
        : ref
            .read(supabaseProvider)
            .storage
            .from('food')
            .getPublicUrl(storageKey);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2E2A22), const Color(0xFF262218)]
              : [const Color(0xFFFFF8EC), const Color(0xFFFDF0D8)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFF0E2C4),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 84,
              height: 84,
              child: imageUrl == null
                  ? ColoredBox(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      child: Icon(
                        Icons.fastfood,
                        color: isDark ? Colors.white54 : Colors.black38,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: isDark ? Colors.white54 : Colors.black38,
                        ),
                      ),
                    ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    t.myMapRecord.memoryToday,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Gap(6),
                if (area != null && area.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: Color(0xFFEF4444),
                      ),
                      const Gap(2),
                      Expanded(
                        child: Text(
                          area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(2),
                ],
                Text(
                  post.restaurant,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF4A3D28),
                  ),
                ),
                const Gap(6),
                Row(
                  children: [
                    Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    const Gap(8),
                    const Icon(
                      Icons.favorite,
                      size: 13,
                      color: Color(0xFFEF4444),
                    ),
                    const Gap(2),
                    Text(
                      '${post.heart}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 今日の投稿がまだ無いときのカード
class _NoTodayCard extends StatelessWidget {
  const _NoTodayCard();

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16283A) : const Color(0xFFEAF3FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Assets.gif.recordNopost.image(
            width: 64,
            height: 64,
            fit: BoxFit.contain,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.myMapRecord.dogNoMemoryTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: isDark ? Colors.white : const Color(0xFF1F3A56),
                  ),
                ),
                const Gap(4),
                Text(
                  t.myMapRecord.dogNoMemoryBody,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: isDark ? Colors.white70 : const Color(0xFF3B5A78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryCarousel extends HookWidget {
  const _MemoryCarousel({required this.memories});

  final List<RecordMemory> memories;

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    const cardWidth = 156.0;
    const spacing = 10.0;

    void scrollBy(double delta) {
      final target = (controller.offset + delta).clamp(
        0.0,
        controller.position.maxScrollExtent,
      );
      controller.animateTo(
        target,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }

    return SizedBox(
      height: 214,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListView.separated(
            controller: controller,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: memories.length,
            separatorBuilder: (_, __) => const Gap(spacing),
            itemBuilder: (context, index) => SizedBox(
              width: cardWidth,
              child: _MemoryCard(memory: memories[index]),
            ),
          ),
          if (memories.length > 1) ...[
            Positioned(
              left: -6,
              child: _CarouselArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () => scrollBy(-(cardWidth + spacing)),
              ),
            ),
            Positioned(
              right: -6,
              child: _CarouselArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () => scrollBy(cardWidth + spacing),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CarouselArrow extends StatelessWidget {
  const _CarouselArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }
}

class _MemoryCard extends ConsumerWidget {
  const _MemoryCard({required this.memory});

  final RecordMemory memory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final post = memory.post;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final label = switch (memory.type) {
      RecordMemoryType.oneWeekAgo => t.myMapRecord.memoryOneWeekAgo,
      RecordMemoryType.oneMonthAgo => t.myMapRecord.memoryOneMonthAgo,
      RecordMemoryType.oneYearAgo => t.myMapRecord.oneYearAgoToday,
    };
    final labelColor = switch (memory.type) {
      RecordMemoryType.oneWeekAgo => const Color(0xFF10B981),
      RecordMemoryType.oneMonthAgo => const Color(0xFF3B82F6),
      RecordMemoryType.oneYearAgo => const Color(0xFFE8A63A),
    };

    if (post == null) {
      return _EmptyMemoryCard(label: label, color: labelColor);
    }

    final dateText = DateFormat('yyyy/M/d', localeTag).format(post.createdAt);
    final area = recordPostAreaLabel(post);
    final storageKey = post.firstFoodImage;
    final imageUrl = storageKey.isEmpty
        ? null
        : ref
            .read(supabaseProvider)
            .storage
            .from('food')
            .getPublicUrl(storageKey);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D1D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFECECEC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 96,
                width: double.infinity,
                child: imageUrl == null
                    ? ColoredBox(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        child: Icon(
                          Icons.fastfood,
                          color: isDark ? Colors.white54 : Colors.black38,
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: isDark ? Colors.white54 : Colors.black38,
                          ),
                        ),
                      ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: labelColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (area != null && area.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: Color(0xFFEF4444),
                      ),
                      const Gap(2),
                      Expanded(
                        child: Text(
                          area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(3),
                ],
                Text(
                  post.restaurant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(6),
                Row(
                  children: [
                    Text(
                      dateText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.favorite,
                      size: 13,
                      color: Color(0xFFEF4444),
                    ),
                    const Gap(2),
                    Text(
                      '${post.heart}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 過去の思い出カードで空状態を表示するウィジェット
class _EmptyMemoryCard extends StatelessWidget {
  const _EmptyMemoryCard({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1D1D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFECECEC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Expanded(
            child: Center(
              child: Assets.gif.recordNopost.image(
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Text(
            t.myMapRecord.memoryEmptyTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

enum RecordMemoryType { oneWeekAgo, oneMonthAgo, oneYearAgo }

class RecordMemory {
  const RecordMemory({required this.type, required this.post});

  final RecordMemoryType type;
  final Posts? post;
}

bool _isSameDay(DateTime date, DateTime target) =>
    date.year == target.year &&
    date.month == target.month &&
    date.day == target.day;

/// 今日の日付の投稿があれば、その中で最新の1件を返す
Posts? recordTodayLatestPost(List<Posts> posts) {
  if (posts.isEmpty) {
    return null;
  }
  final now = DateTime.now();
  final matches = posts.where((p) => _isSameDay(p.createdAt, now)).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return matches.firstOrNull;
}

/// 指定の年月に対して、日付を月末でクランプした DateTime を返す。
/// 例: 3/31 の1ヶ月前は 2/28（うるう年なら 2/29）になる。
DateTime _clampedDate(int year, int month, int day) {
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;
  final clampedDay = day > lastDayOfMonth ? lastDayOfMonth : day;
  return DateTime(year, month, clampedDay);
}

/// 過去の思い出（先週・1ヶ月前・1年前の同日）を常に3件返す。
/// 該当投稿が無いスロットは post を null にして空状態で表示する。
List<RecordMemory> collectPastMemories(List<Posts> posts) {
  final now = DateTime.now();

  Posts? pickLatest(DateTime target) {
    final matches = posts.where((p) => _isSameDay(p.createdAt, target)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches.firstOrNull;
  }

  // 先週の同日: DSTの影響を受けないよう日付ベースで7日戻す
  final weekAgo = _clampedDate(now.year, now.month, now.day - 7);

  return [
    RecordMemory(
      type: RecordMemoryType.oneWeekAgo,
      post: pickLatest(weekAgo),
    ),
    RecordMemory(
      type: RecordMemoryType.oneMonthAgo,
      post: pickLatest(_clampedDate(now.year, now.month - 1, now.day)),
    ),
    RecordMemory(
      type: RecordMemoryType.oneYearAgo,
      post: pickLatest(_clampedDate(now.year - 1, now.month, now.day)),
    ),
  ];
}
