import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/theme/memory_album_theme.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/common/app_tab_error.dart';
import 'package:food_gram_app/ui/component/dialog/memory_album_dialog.dart';
import 'package:food_gram_app/ui/screen/memory_album/memory_album_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MemoryAlbumFormScreen extends HookConsumerWidget {
  const MemoryAlbumFormScreen({this.albumId, super.key});

  final String? albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isEdit = albumId != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleCtrl = useTextEditingController();
    final descCtrl = useTextEditingController();
    final selectedIds = useState<List<int>>(<int>[]);
    final isSaving = useState(false);
    final didPrefill = useRef(false);

    if (isEdit) {
      final albumAsync =
          ref.watch(memoryAlbumDetailViewModelProvider(albumId!));
      useEffect(
        () {
          final album = albumAsync.valueOrNull;
          if (album != null && !didPrefill.value) {
            didPrefill.value = true;
            titleCtrl.text = album.title;
            descCtrl.text = album.description;
            selectedIds.value = List<int>.from(album.postIds);
          }
          return null;
        },
        [albumAsync],
      );
    }

    final myPosts = ref.watch(myPostStreamProvider);

    Future<void> save() async {
      if (isSaving.value) {
        return;
      }
      isSaving.value = true;
      try {
        if (isEdit) {
          final error = await ref
              .read(memoryAlbumDetailViewModelProvider(albumId!).notifier)
              .updateAlbum(
                title: titleCtrl.text,
                description: descCtrl.text,
                postIds: selectedIds.value,
              );
          if (!context.mounted) {
            return;
          }
          if (error == null) {
            ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
                  name: AnalyticsEvent.albumEditComplete,
                  parameters: albumId != null
                      ? {AnalyticsParam.albumId: albumId!}
                      : null,
                );
            SnackBarHelper().openSuccessSnackBar(
              context,
              t.memoryAlbum.saved,
              '',
            );
            context.pop();
            return;
          }
          final message = switch (error) {
            MemoryAlbumError.emptyTitle => t.memoryAlbum.emptyTitleError,
            MemoryAlbumError.emptyPostIds => t.memoryAlbum.emptyPostsError,
            MemoryAlbumError.albumNotFound => t.memoryAlbum.notFound,
            MemoryAlbumError.albumLimitFree => t.memoryAlbum.albumLimitBody,
          };
          SnackBarHelper().openErrorSnackBar(context, message, '');
          return;
        }

        final error = await ref
            .read(memoryAlbumListViewModelProvider.notifier)
            .createAlbum(
              title: titleCtrl.text,
              description: descCtrl.text,
              postIds: selectedIds.value,
            );
        if (!context.mounted) {
          return;
        }
        if (error == null) {
          ref
              .read(firebaseAnalyticsServiceProvider)
              .logEventUnawaited(name: AnalyticsEvent.albumCreate);
          SnackBarHelper().openSuccessSnackBar(
            context,
            t.memoryAlbum.saved,
            '',
          );
          context.pop();
          return;
        }
        if (error == MemoryAlbumError.albumLimitFree) {
          final isPremium = await ref.read(isSubscribeProvider.future);
          if (context.mounted) {
            await showMemoryAlbumLimitDialog(
              context,
              isPremium: isPremium,
            );
          }
          return;
        }
        final message = switch (error) {
          MemoryAlbumError.emptyTitle => t.memoryAlbum.emptyTitleError,
          MemoryAlbumError.emptyPostIds => t.memoryAlbum.emptyPostsError,
          MemoryAlbumError.albumNotFound => t.memoryAlbum.notFound,
          MemoryAlbumError.albumLimitFree => t.memoryAlbum.albumLimitBody,
        };
        SnackBarHelper().openErrorSnackBar(context, message, '');
      } finally {
        isSaving.value = false;
      }
    }

    void togglePost(int id) {
      final list = List<int>.from(selectedIds.value);
      if (list.contains(id)) {
        list.remove(id);
      } else {
        list.add(id);
      }
      selectedIds.value = list;
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDark
            ? Theme.of(context).scaffoldBackgroundColor
            : MemoryAlbumTheme.creamBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            isEdit ? t.memoryAlbum.edit : t.memoryAlbum.create,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            TextButton(
              onPressed:
                  isSaving.value || selectedIds.value.isEmpty ? null : save,
              child: isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      t.save,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: selectedIds.value.isEmpty
                            ? Colors.grey
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: t.memoryAlbum.titleHint,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: descCtrl,
                decoration: InputDecoration(
                  labelText: t.memoryAlbum.descriptionHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    t.memoryAlbum.selectPosts,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  if (selectedIds.value.isNotEmpty)
                    Text(
                      t.memoryAlbum.postCount.replaceAll(
                        '{count}',
                        selectedIds.value.length.toString(),
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: myPosts.when(
                loading: () => const Center(child: AppContentLoading()),
                error: (_, __) => AppTabError.myPage(
                  onRetry: () => ref.invalidate(myPostStreamProvider),
                ),
                data: (posts) {
                  if (posts.isEmpty) {
                    return const AppEmpty();
                  }
                  final supabase = ref.watch(supabaseProvider);
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      final selected = selectedIds.value.contains(post.id);
                      final storageKey = post.firstFoodImage;
                      final imageUrl = storageKey.isEmpty
                          ? null
                          : supabase.storage
                              .from('food')
                              .getPublicUrl(storageKey);
                      return GestureDetector(
                        onTap: () => togglePost(post.id),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (imageUrl == null)
                              ColoredBox(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                                child: Icon(
                                  Icons.fastfood,
                                  color:
                                      isDark ? Colors.white54 : Colors.black38,
                                ),
                              )
                            else
                              CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                              ),
                            if (selected)
                              ColoredBox(
                                color: Colors.black.withValues(alpha: 0.35),
                                child: const Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            Positioned(
                              left: 4,
                              bottom: 4,
                              right: 4,
                              child: Text(
                                post.foodName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(blurRadius: 4),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
