import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/post_draft.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/helpers/haptic_feedback_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class PostDraftPickerSheet extends HookWidget {
  const PostDraftPickerSheet({
    required this.drafts,
    required this.onSelect,
    required this.onDelete,
    required this.onStartNew,
    super.key,
  });

  final List<PostDraft> drafts;
  final ValueChanged<PostDraft> onSelect;
  final Future<List<PostDraft>> Function(Set<String> ids) onDelete;
  final Future<void> Function() onStartNew;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final items = useState<List<PostDraft>>(List<PostDraft>.of(drafts));
    final selecting = useState(false);
    final selected = useState<Set<String>>(const {});
    final deleting = useState(false);
    final startingNew = useState(false);
    final dateFormat = useMemoized(() => DateFormat('yyyy/MM/dd HH:mm'));

    void toggle(String id) {
      final next = {...selected.value};
      if (!next.add(id)) {
        next.remove(id);
      }
      selected.value = next;
      HapticFeedbackHelper.selection();
    }

    void toggleSelectAll() {
      final allIds = items.value.map((draft) => draft.id).toSet();
      final allSelected =
          allIds.isNotEmpty && selected.value.length == allIds.length;
      selected.value = allSelected ? const {} : allIds;
      HapticFeedbackHelper.selection();
    }

    Future<void> deleteSelected() async {
      if (selected.value.isEmpty || deleting.value) {
        return;
      }
      final count = selected.value.length;
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(t.post.deleteDraftsTitle),
            content: Text(
              t.post.deleteDraftsMessage.replaceAll('{count}', '$count'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(t.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  t.post.deleteSelectedDrafts,
                  style: TextStyle(color: scheme.error),
                ),
              ),
            ],
          );
        },
      );
      if (!context.mounted || accepted != true) {
        return;
      }
      deleting.value = true;
      try {
        final latest = await onDelete(Set<String>.of(selected.value));
        if (!context.mounted) {
          return;
        }
        items.value = latest;
        selected.value = const {};
        if (latest.isEmpty) {
          selecting.value = false;
        }
      } finally {
        if (context.mounted) {
          deleting.value = false;
        }
      }
    }

    final allSelected =
        items.value.isNotEmpty && selected.value.length == items.value.length;
    final title = selecting.value
        ? t.post.selectedDraftCount.replaceAll(
            '{count}',
            '${selected.value.length}',
          )
        : t.post.draftsTitle;

    return Material(
      color: scheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Column(
          children: [
            const Gap(10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  if (items.value.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        selecting.value = !selecting.value;
                        if (!selecting.value) {
                          selected.value = const {};
                        }
                      },
                      child: Text(
                        selecting.value ? t.cancel : t.post.selectDrafts,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (selecting.value && items.value.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: TextButton(
                    onPressed: toggleSelectAll,
                    child: Text(
                      allSelected
                          ? t.post.deselectAllDrafts
                          : t.post.selectAllDrafts,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.post.draftPickHint,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: items.value.isEmpty
                  ? Center(
                      child: Text(
                        t.post.draftsEmpty,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: items.value.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: scheme.outlineVariant.withValues(alpha: 0.6),
                      ),
                      itemBuilder: (context, index) {
                        final draft = items.value[index];
                        final isSelected = selected.value.contains(draft.id);
                        return _DraftTile(
                          title: _draftTitle(draft, t.post.draftUntitled),
                          preview: _draftPreview(draft),
                          dateLabel: dateFormat.format(draft.savedAt.toLocal()),
                          selecting: selecting.value,
                          selected: isSelected,
                          onTap: () {
                            if (selecting.value) {
                              toggle(draft.id);
                              return;
                            }
                            onSelect(draft);
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: selecting.value
                  ? SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: selected.value.isEmpty || deleting.value
                            ? null
                            : deleteSelected,
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.error,
                          foregroundColor: scheme.onError,
                          disabledBackgroundColor: scheme.error.withValues(
                            alpha: 0.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          t.post.deleteSelectedDrafts,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: startingNew.value
                            ? null
                            : () async {
                                startingNew.value = true;
                                try {
                                  await onStartNew();
                                } finally {
                                  if (context.mounted) {
                                    startingNew.value = false;
                                  }
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: scheme.onSurface),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          t.post.newDraft,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({
    required this.title,
    required this.preview,
    required this.dateLabel,
    required this.selecting,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String preview;
  final String dateLabel;
  final bool selecting;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? AppTheme.primaryOrange.withValues(alpha: 0.1)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              if (selecting) ...[
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected
                      ? AppTheme.primaryOrange
                      : scheme.onSurfaceVariant,
                ),
                const Gap(12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (preview.isNotEmpty) ...[
                      const Gap(2),
                      Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _draftTitle(PostDraft draft, String untitled) {
  final food = draft.foodName.trim();
  if (food.isNotEmpty) {
    return food;
  }
  final place = draft.restaurant.trim();
  if (place.isNotEmpty && place != '場所を追加' && !isUnknownRestaurantName(place)) {
    return place;
  }
  return untitled;
}

String _draftPreview(PostDraft draft) {
  final text = draft.comment.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (text.isNotEmpty) {
    return text;
  }
  final place = draft.restaurant.trim();
  final food = draft.foodName.trim();
  if (place.isNotEmpty &&
      place != '場所を追加' &&
      !isUnknownRestaurantName(place) &&
      place != food) {
    return place;
  }
  return draft.foodTags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .join(' / ');
}
