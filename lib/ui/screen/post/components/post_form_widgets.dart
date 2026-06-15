import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_gram_app/core/theme/style/post_style.dart';
import 'package:food_gram_app/core/utils/format/post_price_formatter.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/app_tag.dart';
import 'package:gap/gap.dart';

class PostSectionCard extends StatelessWidget {
  const PostSectionCard({
    required this.accent,
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
    super.key,
  });

  final Color accent;
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class PostSectionHeader extends StatelessWidget {
  const PostSectionHeader({
    required this.title,
    required this.badge,
    required this.accent,
    this.hint,
    this.subtitle,
    super.key,
  });

  final String title;
  final String badge;
  final String? hint;
  final String? subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hasHint = hint != null && hint!.isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: PostStyle.sectionTitle(context)),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (hasHint) ...[
              const Spacer(),
              Text(hint!, style: PostStyle.sectionHint(accent)),
            ],
          ],
        ),
        if (hasSubtitle) ...[
          const Gap(4),
          Text(subtitle!, style: PostStyle.sectionSubtitle(context)),
        ],
      ],
    );
  }
}

class PostFieldLabel extends StatelessWidget {
  const PostFieldLabel({
    required this.icon,
    required this.label,
    required this.accent,
    super.key,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: accent),
        const Gap(6),
        Text(label, style: PostStyle.fieldLabel(accent)),
      ],
    );
  }
}

class PostTextInputField extends StatelessWidget {
  const PostTextInputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PostStyle.fieldBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autocorrect: false,
        contextMenuBuilder: (context, state) {
          if (SystemContextMenu.isSupported(context)) {
            return SystemContextMenu.editableText(editableTextState: state);
          }
          return AdaptiveTextSelectionToolbar.editableText(
            editableTextState: state,
          );
        },
        selectionHeightStyle: BoxHeightStyle.strut,
        style: PostStyle.fieldValue(context),
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          hintText: hint,
          hintStyle: PostStyle.fieldHint(context),
        ),
      ),
    );
  }
}

class PostPhotoArea extends StatelessWidget {
  const PostPhotoArea({
    required this.foodImages,
    required this.deviceWidth,
    required this.previewWidth,
    required this.previewHeight,
    required this.onAddPhoto,
    required this.onRemoveImage,
    required this.accent,
    required this.borderColor,
    super.key,
  });

  final List<String> foodImages;
  final double deviceWidth;
  final int previewWidth;
  final int previewHeight;
  final VoidCallback onAddPhoto;
  final ValueChanged<String> onRemoveImage;
  final Color accent;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    if (foodImages.isEmpty) {
      return GestureDetector(
        onTap: onAddPhoto,
        child: Container(
          width: double.infinity,
          height: deviceWidth / 1.9,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                size: 36,
                color: accent,
              ),
              const Gap(8),
              Text(
                t.post.addPhotoRequired,
                style: PostStyle.fieldLabel(accent),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: deviceWidth / 1.9,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: foodImages.length + 1,
        itemBuilder: (context, index) {
          if (index == foodImages.length) {
            return Padding(
              padding: const EdgeInsets.only(left: 10),
              child: GestureDetector(
                onTap: onAddPhoto,
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Icon(Icons.add, size: 32, color: accent),
                ),
              ),
            );
          }

          final imagePath = foodImages[index];
          return Padding(
            padding: EdgeInsets.only(right: index < foodImages.length ? 10 : 0),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  width: deviceWidth * 0.75,
                  height: deviceWidth / 1.9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      cacheWidth: previewWidth,
                      cacheHeight: previewHeight,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => onRemoveImage(imagePath),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PostRestaurantField extends StatelessWidget {
  const PostRestaurantField({
    required this.restaurant,
    required this.defaultRestaurantText,
    required this.onTap,
    required this.accent,
    super.key,
  });

  final String restaurant;
  final String defaultRestaurantText;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isPlaceholder = restaurant == defaultRestaurantText;
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PostStyle.fieldBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isPlaceholder
                      ? t.post.restaurantNamePlaceholder
                      : restaurant,
                  overflow: TextOverflow.ellipsis,
                  style: isPlaceholder
                      ? PostStyle.fieldHint(context)
                      : PostStyle.fieldValue(context),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 22,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostFoodTagField extends StatelessWidget {
  const PostFoodTagField({
    required this.foodTags,
    required this.foodTexts,
    required this.onTagSelected,
    required this.accent,
    super.key,
  });

  final List<String> foodTags;
  final ValueNotifier<List<String>> foodTexts;
  final ValueChanged<List<String>> onTagSelected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostFieldLabel(
          icon: Icons.sell_outlined,
          label: t.post.foodTagLabel,
          accent: accent,
        ),
        const Gap(8),
        AppFoodTag(
          foodTags: foodTags,
          foodTexts: foodTexts,
          onTagSelected: onTagSelected,
          emptyHint: t.post.foodTagPlaceholder,
        ),
      ],
    );
  }
}

class PostPriceField extends StatelessWidget {
  const PostPriceField({
    required this.controller,
    required this.currencyCode,
    required this.onCurrencyChanged,
    required this.accent,
    super.key,
  });

  final TextEditingController controller;
  final String currencyCode;
  final ValueChanged<String> onCurrencyChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final code = currencyCode.isEmpty
        ? defaultPostPriceCurrencyForLocale()
        : currencyCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostFieldLabel(
          icon: Icons.payments_outlined,
          label: t.post.priceOptionalLabel,
          accent: accent,
        ),
        const Gap(8),
        Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: PostStyle.fieldBorder),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    postPriceInputFormatter(
                      locale: Localizations.localeOf(context),
                      currencyCode: code,
                    ),
                  ],
                  contextMenuBuilder: (context, state) {
                    if (SystemContextMenu.isSupported(context)) {
                      return SystemContextMenu.editableText(
                        editableTextState: state,
                      );
                    }
                    return AdaptiveTextSelectionToolbar.editableText(
                      editableTextState: state,
                    );
                  },
                  selectionHeightStyle: BoxHeightStyle.strut,
                  style: PostStyle.fieldValue(context),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: t.post.priceHint,
                    hintStyle: PostStyle.fieldHint(context),
                  ),
                  autocorrect: false,
                ),
              ),
            ),
            const Gap(8),
            Material(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  primaryFocus?.unfocus();
                  _openCurrencySheet(context, code);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 72,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PostStyle.fieldBorder),
                  ),
                  child: Text(
                    code,
                    style: PostStyle.fieldValue(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _openCurrencySheet(BuildContext context, String selected) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: theme.brightness == Brightness.light
          ? Colors.white
          : theme.colorScheme.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.builder(
            itemCount: kSupportedPostPriceCurrencies.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    t.post.selectCurrency,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                );
              }
              final c = kSupportedPostPriceCurrencies[index - 1];
              final sym = postPriceCurrencySymbol(c);
              return ListTile(
                title: Text('$sym  $c'),
                trailing: c == selected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  onCurrencyChanged(c);
                  Navigator.of(sheetContext).pop();
                },
              );
            },
          ),
        );
      },
    );
  }
}

class PostRatingField extends StatelessWidget {
  const PostRatingField({
    required this.star,
    required this.onRatingUpdate,
    required this.accent,
    super.key,
  });

  final double star;
  final ValueChanged<double> onRatingUpdate;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostFieldLabel(
          icon: Icons.star_outline,
          label: t.post.ratingOptionalLabel,
          accent: accent,
        ),
        const Gap(8),
        Row(
          children: [
            KeyedSubtree(
              key: ValueKey(star),
              child: RatingBar.builder(
                initialRating: star,
                allowHalfRating: true,
                itemSize: 34,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                unratedColor:
                    isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: onRatingUpdate,
              ),
            ),
            const Gap(8),
            Text(
              star.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PostCommentField extends HookWidget {
  const PostCommentField({
    required this.controller,
    required this.accent,
    this.maxLength = 300,
    super.key,
  });

  final TextEditingController controller;
  final Color accent;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final length = useListenableSelector(
      controller,
      () => controller.text.characters.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostFieldLabel(
          icon: Icons.chat_bubble_outline,
          label: t.post.commentOptionalLabel,
          accent: accent,
        ),
        const Gap(8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PostStyle.fieldBorder),
          ),
          child: Column(
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: 4,
                maxLength: maxLength,
                buildCounter: (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) =>
                    null,
                contextMenuBuilder: (context, state) {
                  if (SystemContextMenu.isSupported(context)) {
                    return SystemContextMenu.editableText(
                      editableTextState: state,
                    );
                  }
                  return AdaptiveTextSelectionToolbar.editableText(
                    editableTextState: state,
                  );
                },
                selectionHeightStyle: BoxHeightStyle.strut,
                style: PostStyle.fieldValue(context),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  hintText: t.post.commentPlaceholder,
                  hintStyle: PostStyle.fieldHint(context),
                ),
                autocorrect: false,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$length / $maxLength',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
