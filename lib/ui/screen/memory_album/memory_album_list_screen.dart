import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/theme/memory_album_theme.dart';
import 'package:food_gram_app/core/utils/helpers/dialog_helper.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_error_widget.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/dialog/memory_album_dialog.dart';
import 'package:food_gram_app/ui/screen/memory_album/components/memory_album_card.dart';
import 'package:food_gram_app/ui/screen/memory_album/memory_album_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MemoryAlbumListScreen extends HookConsumerWidget {
  const MemoryAlbumListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final albumsAsync = ref.watch(memoryAlbumListViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Future<void> reload() async {
      await ref.read(memoryAlbumListViewModelProvider.notifier).reload();
    }

    void showAlbumActions(MemoryAlbum album) {
      showModalBottomSheet<void>(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(t.memoryAlbum.deleteTitle),
                  onTap: () async {
                    Navigator.pop(context);
                    DialogHelper().openDialog(
                      context: context,
                      title: t.memoryAlbum.deleteTitle,
                      text: t.memoryAlbum.deleteBody,
                      onTap: () async {
                        context.pop();
                        final deleted =
                            await deleteMemoryAlbum(context, ref, album.id);
                        if (deleted && context.mounted) {
                          SnackBarHelper().openSuccessSnackBar(
                            context,
                            t.memoryAlbum.deleted,
                            '',
                          );
                        }
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(t.cancel),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : MemoryAlbumTheme.creamBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          t.memoryAlbum.title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.black87,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                size: 20,
                color: isDark ? Colors.white : Colors.white,
              ),
            ),
            tooltip: t.memoryAlbum.create,
            onPressed: () => unawaited(openMemoryAlbumCreate(context, ref)),
          ),
          const Gap(4),
        ],
      ),
      body: albumsAsync.when(
        loading: () => const Center(child: AppContentLoading()),
        error: (_, __) => AppErrorWidget(onTap: reload),
        data: (albums) {
          if (albums.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_album_outlined,
                      size: 72,
                      color: isDark ? Colors.white24 : Colors.amber.shade200,
                    ),
                    const Gap(20),
                    Text(
                      t.memoryAlbum.emptyTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      t.memoryAlbum.listSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const Gap(28),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () =>
                          unawaited(openMemoryAlbumCreate(context, ref)),
                      icon: const Icon(Icons.add),
                      label: Text(t.memoryAlbum.create),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  t.memoryAlbum.listSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: reload,
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    itemCount: albums.length,
                    onReorder: (oldIndex, newIndex) async {
                      final list = List<MemoryAlbum>.from(albums);
                      var targetIndex = newIndex;
                      if (targetIndex > oldIndex) {
                        targetIndex -= 1;
                      }
                      final item = list.removeAt(oldIndex);
                      list.insert(targetIndex, item);
                      await ref
                          .read(memoryAlbumListViewModelProvider.notifier)
                          .reorder(list);
                    },
                    itemBuilder: (context, index) {
                      final album = albums[index];
                      return ReorderableDelayedDragStartListener(
                        key: ValueKey(album.id),
                        index: index,
                        child: MemoryAlbumCard(
                          album: album,
                          onTap: () async {
                            await context.pushNamed(
                              RouterPath.memoryAlbumDetail,
                              extra: album.id,
                            );
                            if (!context.mounted) {
                              return;
                            }
                            await reload();
                          },
                          onDelete: () => showAlbumActions(album),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Text(
                  t.memoryAlbum.longPressHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
