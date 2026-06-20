import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/modal_sheet/save_album_picker_sheet.dart';
import 'package:food_gram_app/ui/screen/memory_album/memory_album_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> showMemoryAlbumLimitDialog(
  BuildContext context, {
  required bool isPremium,
}) async {
  final t = Translations.of(context);
  if (!context.mounted) {
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t.stored.albumLimitTitle),
      content: Text(t.memoryAlbum.albumLimitBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(t.close),
        ),
        if (!isPremium)
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  unawaited(openSaveAlbumPaywall(context));
                }
              });
            },
            child: Text(t.stored.albumPremiumCta),
          ),
      ],
    ),
  );
}

Future<void> openMemoryAlbumCreate(
  BuildContext context,
  WidgetRef ref,
) async {
  final isPremium = await ref.read(isSubscribeProvider.future);
  if (!isPremium) {
    final albums = await ref.read(memoryAlbumListViewModelProvider.future);
    if (albums.length >= MemoryAlbumLimits.freeMaxAlbums) {
      if (context.mounted) {
        await showMemoryAlbumLimitDialog(context, isPremium: false);
      }
      return;
    }
  }
  if (!context.mounted) {
    return;
  }
  await context.pushNamed(RouterPath.memoryAlbumCreate);
  await ref.read(memoryAlbumListViewModelProvider.notifier).reload();
}
