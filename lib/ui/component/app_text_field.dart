import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/restaurant_group.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/utils/format/post_price_formatter.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/modal_sheet/map_place_search_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/map_restaurant_overview_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/map/map_view_model.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef OnSubmitted = void Function(String value);

class AppSearchTextField extends HookWidget {
  const AppSearchTextField({
    required this.onSubmitted,
    this.initialText = '',
    super.key,
  });

  final OnSubmitted? onSubmitted;
  final String initialText;

  @override
  Widget build(BuildContext context) {
    final searchText = useState<String>(initialText);
    final controller = useTextEditingController(text: initialText);
    useEffect(
      () {
        controller.text = initialText;
        searchText.value = initialText;
        return null;
      },
      [initialText],
    );
    const bgColor = Colors.white;
    const textColor = Colors.black87;
    const hintColor = Colors.black54;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: Material(
              elevation: 10,
              shadowColor: Colors.black38,
              color: Colors.transparent,
              borderRadius: const BorderRadius.all(Radius.circular(18)),
              child: TextField(
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
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: bgColor,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 10,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(Icons.search, color: textColor, size: 24),
                  ),
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: hintColor),
                  label: Text(Translations.of(context).app.restaurantLabel),
                  labelStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: textColor),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                autocorrect: false,
                controller: controller,
                onSubmitted: (_) {
                  onSubmitted!(controller.text);
                },
                onChanged: (text) {
                  searchText.value = text;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Map 画面用: 検索バー→検索モーダル→タップでカメラ移動 & ModalSheet更新
class AppMapPlaceSearchTextField extends ConsumerWidget {
  const AppMapPlaceSearchTextField({
    required this.mapController,
    super.key,
  });

  final MapViewModel mapController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppSearchTextField(
      onSubmitted: (value) async {
        final keyword = value.trim();
        if (keyword.isEmpty) {
          return;
        }
        FocusManager.instance.primaryFocus?.unfocus();
        unawaited(
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (sheetContext) => SizedBox(
              height: MediaQuery.of(sheetContext).size.height * 0.8,
              child: MapPlaceSearchModalSheet(
                initialQuery: keyword,
                onRestaurantSelected: (restaurant) async {
                  final postsResult = await ref
                      .read(mapPostRepositoryProvider.notifier)
                      .getRestaurantPosts(
                        lat: restaurant.lat,
                        lng: restaurant.lng,
                      );
                  final hasPosts = postsResult.whenOrNull(
                        success: (posts) => posts.isNotEmpty,
                      ) ??
                      false;

                  await mapController.animateToLatLng(
                    lat: restaurant.lat,
                    lng: restaurant.lng,
                  );
                  mapController.setNearbySearchCenterFromLatLng(
                    lat: restaurant.lat,
                    lng: restaurant.lng,
                  );

                  ref.read(mapModalSelectionProvider.notifier).state =
                      MapModalSelection(
                    name: restaurant.name,
                    lat: restaurant.lat,
                    lng: restaurant.lng,
                    placeSearchRestaurant: restaurant,
                  );

                  // 投稿がある地点ではマーカーは出さない（投稿グリッドで十分なため）
                  if (hasPosts) {
                    await mapController.clearSearchResultPin();
                  } else {
                    await mapController.setSearchResultPin(
                      restaurant.lat,
                      restaurant.lng,
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class AppFoodTextField extends StatelessWidget {
  const AppFoodTextField({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          const Gap(5),
          Icon(
            Icons.fastfood,
            color: scheme.onSurface,
            size: 28,
          ),
          const Gap(10),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: TextField(
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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: Translations.of(context).post.foodNameInputField,
                  hintStyle: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                controller: controller,
                keyboardType: TextInputType.text,
                autocorrect: false,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppCommentTextField extends StatelessWidget {
  const AppCommentTextField({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: TextField(
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
        decoration: InputDecoration(
          alignLabelWithHint: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          hintText: Translations.of(context).post.comment,
          hintStyle: TextStyle(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        controller: controller,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        maxLines: 6,
        autocorrect: false,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: scheme.onSurface,
          fontSize: 15,
        ),
      ),
    );
  }
}

class AppNameTextField extends StatelessWidget {
  const AppNameTextField({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              label: 'nameField',
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: TextField(
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
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: Translations.of(context).newAccount.userName,
                    hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                    label: Text(
                      Translations.of(context).newAccount.userNameInputField,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  controller: controller,
                  autocorrect: false,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppSelfIntroductionTextField extends StatelessWidget {
  const AppSelfIntroductionTextField({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              label: 'selfIntroductionField',
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: TextField(
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
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: Translations.of(context).edit.bioInputField,
                    hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                    label: Text(
                      Translations.of(context).edit.bio,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  controller: controller,
                  maxLines: 5,
                  autocorrect: false,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppUserNameTextField extends StatelessWidget {
  const AppUserNameTextField({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          const Gap(10),
          Expanded(
            child: Semantics(
              label: 'userNameField',
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: TextField(
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
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    hintText: Translations.of(context).newAccount.userId,
                    hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                    label: Text(
                      Translations.of(context).newAccount.userIdInputField,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  controller: controller,
                  autocorrect: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp('[a-zA-Z0-9@_.-]'),
                    ),
                  ],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 投稿・編集で共通。アイコン＋金額入力＋通貨ピッカー（Bottom sheet）。
class AppPostPriceInputRow extends StatelessWidget {
  const AppPostPriceInputRow({
    required this.controller,
    required this.currencyCode,
    required this.onCurrencyChanged,
    super.key,
  });

  final TextEditingController controller;
  final String currencyCode;
  final ValueChanged<String> onCurrencyChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Translations.of(context);
    final code = currencyCode.isEmpty
        ? defaultPostPriceCurrencyFromPlatform()
        : currencyCode;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(5),
          Icon(
            Icons.payments,
            color: scheme.onSurface,
            size: 28,
          ),
          const Gap(10),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: t.post.priceHint,
                  hintStyle: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                autocorrect: false,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const Gap(8),
          Material(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () {
                primaryFocus?.unfocus();
                _openCurrencySheet(context, code);
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
