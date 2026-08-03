import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/local/providers/want_to_go_notifier.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/want_to_go_item.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/common/app_tab_error.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/stored_post_body.dart';
import 'package:food_gram_app/ui/screen/profile/my_profile/stored_post_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

enum _WantToGoHubTab { places, saved }

class WantToGoListScreen extends HookConsumerWidget {
  const WantToGoListScreen({super.key});

  static const _accentOrange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = useState(_WantToGoHubTab.places);
    final listAsync = ref.watch(wantToGoNotifierProvider);
    final savedAsync = ref.watch(storedPostListProvider(null));
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg =
        isDark ? Theme.of(context).colorScheme.surface : Colors.white;
    final muted = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final border = isDark ? Colors.white24 : const Color(0xFFE5E5E5);

    final savedPosts = savedAsync.valueOrNull ?? const <Posts>[];
    final postsByPlace = <String, List<Posts>>{};
    for (final post in savedPosts) {
      final key = WantToGoItem.identityKey(
        name: post.restaurant,
        lat: post.lat,
        lng: post.lng,
      );
      postsByPlace.putIfAbsent(key, () => <Posts>[]).add(post);
    }

    return Scaffold(
      backgroundColor: sheetBg,
      appBar: AppBar(
        backgroundColor: sheetBg,
        surfaceTintColor: sheetBg,
        title: Text(
          t.wantToGo.title,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SegmentedButton<_WantToGoHubTab>(
              segments: [
                ButtonSegment<_WantToGoHubTab>(
                  value: _WantToGoHubTab.places,
                  label: Text(t.wantToGo.tabPlaces),
                  icon: const Icon(Icons.place_outlined, size: 18),
                ),
                ButtonSegment<_WantToGoHubTab>(
                  value: _WantToGoHubTab.saved,
                  label: Text(t.wantToGo.tabSaved),
                  icon: const Icon(Icons.bookmark_border, size: 18),
                ),
              ],
              selected: {selectedTab.value},
              onSelectionChanged: (selected) {
                selectedTab.value = selected.first;
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Expanded(
            child: selectedTab.value == _WantToGoHubTab.saved
                ? const StoredPostBody()
                : listAsync.when(
                    loading: () => const Center(child: AppContentLoading()),
                    error: (_, __) => AppTabError.myPage(
                      onRetry: () =>
                          ref.invalidate(wantToGoNotifierProvider),
                    ),
                    data: (items) {
                      if (items.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const AppEmpty(),
                                const SizedBox(height: 8),
                                Text(
                                  t.wantToGo.emptyHint,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: muted),
                                ),
                                if (savedPosts.isNotEmpty) ...[
                                  const Gap(20),
                                  TextButton.icon(
                                    onPressed: () {
                                      selectedTab.value = _WantToGoHubTab.saved;
                                    },
                                    icon: const Icon(Icons.bookmark_border),
                                    label: Text(t.wantToGo.seeSavedPosts),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }

                      final sorted = List<WantToGoItem>.from(items)
                        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: sorted.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = sorted[index];
                          final dateLabel =
                              _formatAddedDate(context, item.addedAt);
                          final related = postsByPlace[item.id] ?? const [];

                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: border),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                14,
                                14,
                                12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryBlue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.place,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const Gap(10),
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: t.wantToGo.removeFromList,
                                        onPressed: () async {
                                          await ref
                                              .read(
                                                wantToGoNotifierProvider
                                                    .notifier,
                                              )
                                              .removeById(item.id);
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: muted,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: muted,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        t.wantToGo.addedOn
                                            .replaceAll('{date}', dateLabel),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (related.isNotEmpty) ...[
                                    const Gap(12),
                                    Text(
                                      t.wantToGo.relatedSavedPosts,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: muted,
                                      ),
                                    ),
                                    const Gap(8),
                                    _RelatedSavedPostStrip(
                                      posts: related,
                                      allSavedPosts: savedPosts,
                                      isDark: isDark,
                                    ),
                                  ],
                                  const Gap(12),
                                  Material(
                                    color: isDark
                                        ? _accentOrange.withValues(alpha: 0.18)
                                        : const Color(0xFFFFF3E6),
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: () => context.pushNamed(
                                        RouterPath.myProfilePost,
                                        extra: item.toRestaurant(),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                              color: _accentOrange,
                                            ),
                                            const Gap(8),
                                            Expanded(
                                              child: Text(
                                                t.wantToGo.postAfterVisit,
                                                style: const TextStyle(
                                                  color: _accentOrange,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right,
                                              size: 20,
                                              color: _accentOrange,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RelatedSavedPostStrip extends ConsumerWidget {
  const _RelatedSavedPostStrip({
    required this.posts,
    required this.allSavedPosts,
    required this.isDark,
  });

  final List<Posts> posts;
  final List<Posts> allSavedPosts;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final post = posts[index];
          final storageKey = post.firstFoodImage;
          final imageUrl = storageKey.isEmpty
              ? ''
              : supabase.storage.from('food').getPublicUrl(storageKey);

          return GestureDetector(
            onTap: () {
              EasyDebounce.debounce(
                'want_to_go_related_post',
                const Duration(milliseconds: 200),
                () async {
                  final postIndex = allSavedPosts.indexWhere(
                    (p) => p.id == post.id,
                  );
                  if (postIndex < 0) {
                    return;
                  }
                  final postResult = await ref
                      .read(detailPostRepositoryProvider.notifier)
                      .getPostData(allSavedPosts, postIndex);
                  await postResult.whenOrNull(
                    success: (model) async {
                      await context.pushNamed(
                        RouterPath.storedPostDetail,
                        extra: model,
                      );
                      ref.invalidate(storedPostListProvider(null));
                    },
                  );
                },
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 72,
                child: imageUrl.isEmpty
                    ? ColoredBox(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => ColoredBox(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                        errorWidget: (_, __, ___) => Image.asset(
                          isDark
                              ? Assets.image.emptyDark.path
                              : Assets.image.empty.path,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _formatAddedDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context);
  final candidates = <String>{
    locale.toString(),
    locale.languageCode,
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty)
      '${locale.languageCode}_${locale.countryCode}',
  };
  for (final tag in candidates) {
    try {
      return DateFormat('yyyy.MM.dd (E)', tag).format(date);
    } on Object {
      // try next candidate
    }
  }
  return DateFormat('yyyy.MM.dd').format(date);
}
