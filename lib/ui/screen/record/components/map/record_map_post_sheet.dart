import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/model.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/block_list_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/user/repository/user_repository.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 記録タブ（日本／世界マップ）のピンタップ時に投稿を表示するシート
class RecordMapPostSheet extends ConsumerWidget {
  const RecordMapPostSheet({
    required this.post,
    super.key,
  });

  final List<Posts?> post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final sheetHeight = MediaQuery.of(context).size.height * 0.125;
    final entries = <({Posts p, int index})>[];
    for (var i = 0; i < post.length; i++) {
      final p = post[i];
      if (p != null) {
        entries.add((p: p, index: i));
      }
    }
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        elevation: 12,
        color: surface,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: sheetHeight,
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: entries.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            itemBuilder: (context, i) {
              final e = entries[i];
              return _RecordMapPostTile(
                post: e.p,
                postList: post,
                index: e.index,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RecordMapPostTile extends ConsumerWidget {
  const _RecordMapPostTile({
    required this.post,
    required this.postList,
    required this.index,
  });

  final Posts post;
  final List<Posts?> postList;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final supabase = ref.watch(supabaseProvider);
    final storageKey = post.firstFoodImage;
    final imageUrl = storageKey.isEmpty
        ? null
        : supabase.storage.from('food').getPublicUrl(storageKey);
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    const tileHeight = 74.0;
    const thumbSize = 62.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          EasyDebounce.debounce(
            'record_map_pin_detail',
            Duration.zero,
            () async {
              final userResult = await ref
                  .read(userRepositoryProvider.notifier)
                  .getUserFromPost(postList[index]!);
              await userResult.whenOrNull(
                success: (postUsers) async {
                  final model = Model(postUsers, postList[index]!);
                  final value = await context.pushNamed(
                    RouterPath.mapDetail,
                    extra: model,
                  );
                  if (value != null && context.mounted) {
                    ref
                      ..invalidate(postsStreamProvider)
                      ..invalidate(blockListProvider);
                  }
                },
              );
            },
          );
        },
        child: SizedBox(
          height: tileHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: thumbSize,
                    height: thumbSize,
                    child: imageUrl == null
                        ? ColoredBox(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            child: Icon(
                              Icons.restaurant,
                              size: 24,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Image.asset(
                              isDark
                                  ? Assets.image.emptyDark.path
                                  : Assets.image.empty.path,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.foodName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.restaurant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
