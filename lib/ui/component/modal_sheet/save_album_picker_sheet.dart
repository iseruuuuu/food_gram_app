import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/local/providers/save_album_notifier.dart';
import 'package:food_gram_app/core/local/save_album_local_repository.dart';
import 'package:food_gram_app/core/model/save_album.dart';
import 'package:food_gram_app/core/purchase/services/revenue_cat_service.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> openSaveAlbumPaywall(BuildContext context) async {
  if (!context.mounted) {
    return;
  }
  final container = ProviderScope.containerOf(context);
  try {
    await container.read(revenueCatServiceProvider.future);
    await container
        .read(revenueCatServiceProvider.notifier)
        .presentPaywallGuarded();
  } on Object catch (e, st) {
    debugPrint('openSaveAlbumPaywall: $e\n$st');
  }
}

Future<void> showSaveAlbumIssueDialog(
  BuildContext context,
  SaveAlbumIssue issue,
) async {
  final t = Translations.of(context);
  final title = t.stored.albumLimitTitle;
  final body = switch (issue) {
    SaveAlbumIssue.albumLimitFree => t.stored.albumLimitBody,
    SaveAlbumIssue.postLimitFree => t.stored.albumPostLimitBody,
    SaveAlbumIssue.emptyName => t.stored.albumEmptyName,
    SaveAlbumIssue.postNotInSavedList => t.stored.albumNotSavedPost,
  };
  final showPremium = issue == SaveAlbumIssue.albumLimitFree ||
      issue == SaveAlbumIssue.postLimitFree;
  if (!context.mounted) {
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(t.close),
        ),
        if (showPremium)
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

Future<void> showCreateAlbumDialog({
  required BuildContext context,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _CreateAlbumAlertDialog(parentContext: context),
  );
}

/// TextEditingController を [State.dispose] で破棄し、閉じるアニメーションと競合しないようにする
class _CreateAlbumAlertDialog extends ConsumerStatefulWidget {
  const _CreateAlbumAlertDialog({required this.parentContext});

  final BuildContext parentContext;

  @override
  ConsumerState<_CreateAlbumAlertDialog> createState() =>
      _CreateAlbumAlertDialogState();
}

class _CreateAlbumAlertDialogState
    extends ConsumerState<_CreateAlbumAlertDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return AlertDialog(
      title: Text(t.stored.albumNew),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: t.stored.albumNameHint,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        TextButton(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            final issue = await ref
                .read(saveAlbumNotifierProvider.notifier)
                .createAlbum(_controller.text);
            if (!context.mounted) {
              return;
            }
            if (issue != null) {
              Navigator.of(context).pop();
              if (!widget.parentContext.mounted) {
                return;
              }
              await showSaveAlbumIssueDialog(widget.parentContext, issue);
              return;
            }
            Navigator.of(context).pop();
            if (widget.parentContext.mounted) {
              SnackBarHelper().openSimpleSnackBar(
                widget.parentContext,
                t.stored.albumCreated,
              );
            }
          },
          child: Text(t.done),
        ),
      ],
    );
  }
}

Future<void> showSaveAlbumPickerSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int postId,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final viewInsets = MediaQuery.viewInsetsOf(sheetContext);
      final screenHeight = MediaQuery.sizeOf(sheetContext).height;
      return AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
          child: SaveAlbumPickerSheet(postId: postId),
        ),
      );
    },
  );
}

class SaveAlbumPickerSheet extends HookConsumerWidget {
  const SaveAlbumPickerSheet({
    required this.postId,
    super.key,
  });

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final albumsAsync = ref.watch(saveAlbumNotifierProvider);
    final selected = useState<Set<String>>({});
    final newNameController = useTextEditingController();
    final isSaving = useState(false);

    useEffect(
      () {
        var active = true;
        () async {
          final initial =
              await SaveAlbumLocalRepository().albumIdsContainingPost(postId);
          if (active) {
            selected.value = Set<String>.from(initial);
          }
        }();
        return () {
          active = false;
        };
      },
      [postId],
    );

    return SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.stored.albumPickerTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(12),
              albumsAsync.when(
                data: (albums) {
                  if (albums.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        t.stored.albumEmptyListHint,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  return SizedBox(
                    height: 220,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (final a in albums)
                          CheckboxListTile(
                            value: selected.value.contains(a.id),
                            onChanged: (on) {
                              final next = Set<String>.from(selected.value);
                              if (on ?? false) {
                                next.add(a.id);
                              } else {
                                next.remove(a.id);
                              }
                              selected.value = next;
                            },
                            title: Text(a.name),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(t.stored.albumLoadError),
                ),
              ),
              const Gap(8),
              TextField(
                controller: newNameController,
                decoration: InputDecoration(
                  labelText: t.stored.albumCreateFieldLabel,
                  hintText: t.stored.albumNameHint,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
              ),
              const Gap(8),
              OutlinedButton(
                onPressed: isSaving.value
                    ? null
                    : () async {
                        isSaving.value = true;
                        final issue = await ref
                            .read(saveAlbumNotifierProvider.notifier)
                            .createAlbum(newNameController.text);
                        isSaving.value = false;
                        if (!context.mounted) {
                          return;
                        }
                        if (issue != null) {
                          await showSaveAlbumIssueDialog(context, issue);
                          return;
                        }
                        newNameController.clear();
                        SnackBarHelper().openSimpleSnackBar(
                          context,
                          t.stored.albumCreated,
                        );
                      },
                child: Text(t.stored.albumNew),
              ),
              const Gap(16),
              FilledButton(
                onPressed: isSaving.value
                    ? null
                    : () async {
                        isSaving.value = true;
                        final issue = await ref
                            .read(saveAlbumNotifierProvider.notifier)
                            .applyMembership(
                              postId: postId,
                              albumIds: selected.value,
                            );
                        isSaving.value = false;
                        if (!context.mounted) {
                          return;
                        }
                        if (issue != null) {
                          await showSaveAlbumIssueDialog(context, issue);
                          return;
                        }
                        Navigator.of(context).pop();
                      },
                child: Text(t.done),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
