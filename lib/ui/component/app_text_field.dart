import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/utils/format/post_price_formatter.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/modal_sheet/map_place_search_modal_sheet.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final bgColor = scheme.surface;
    final textColor = scheme.onSurface;
    final hintColor = scheme.onSurfaceVariant;
    final borderColor = scheme.outlineVariant;
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
              child: _SearchTextField(
                controller: controller,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: bgColor,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 10,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(Icons.search, color: textColor, size: 24),
                  ),
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: hintColor),
                  label: Text(
                    Translations.of(context).restaurant.searchPlaceholder,
                  ),
                  labelStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: textColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
                onSubmitted: () => onSubmitted?.call(controller.text),
                onChanged: (text) => searchText.value = text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 長押しの単語選択は TextField の認識器のまま行う。
/// 押下位置が未設定のときだけ、ジェスチャの座標を記録してから通常の選択に進む。
class _SearchSelectionGestureDetectorBuilder
    extends TextSelectionGestureDetectorBuilder {
  _SearchSelectionGestureDetectorBuilder({
    required _SearchTextFieldState delegate,
  }) : super(delegate: delegate);

  @override
  void onSingleLongTapStart(LongPressStartDetails details) {
    if (!delegate.selectionEnabled) {
      return;
    }
    renderEditable.handleTapDown(
      TapDownDetails(globalPosition: details.globalPosition),
    );
    super.onSingleLongTapStart(details);
  }
}

class _SearchTextField extends StatefulWidget {
  const _SearchTextField({
    required this.controller,
    required this.style,
    required this.decoration,
    required this.onSubmitted,
    required this.onChanged,
  });

  final TextEditingController controller;
  final TextStyle style;
  final InputDecoration decoration;
  final VoidCallback onSubmitted;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<_SearchTextField>
    implements TextSelectionGestureDetectorBuilderDelegate {
  late final _SearchSelectionGestureDetectorBuilder _gestures;
  final FocusNode _focusNode = FocusNode();
  bool _showSelectionHandles = false;

  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled =>
      Theme.of(context).platform == TargetPlatform.iOS;

  @override
  bool get selectionEnabled => true;

  @override
  void initState() {
    super.initState();
    _gestures = _SearchSelectionGestureDetectorBuilder(delegate: this);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSelectionChanged(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    final showHandles = _gestures.shouldShowSelectionToolbar &&
        _gestures.shouldShowSelectionHandles &&
        cause != SelectionChangedCause.keyboard &&
        (cause == SelectionChangedCause.longPress ||
            widget.controller.text.isNotEmpty);
    if (showHandles != _showSelectionHandles) {
      setState(() => _showSelectionHandles = showHandles);
    }
    if (cause == SelectionChangedCause.longPress) {
      editableTextKey.currentState?.bringIntoView(selection.extent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApple = theme.platform == TargetPlatform.iOS ||
        theme.platform == TargetPlatform.macOS;
    final selectionStyle = TextSelectionTheme.of(context);
    final cursorColor = selectionStyle.cursorColor ??
        (isApple
            ? CupertinoTheme.of(context).primaryColor
            : theme.colorScheme.primary);
    final selectionColor =
        selectionStyle.selectionColor ?? cursorColor.withValues(alpha: 0.4);

    return TextFieldTapRegion(
      child: _gestures.buildGestureDetector(
        behavior: HitTestBehavior.translucent,
        child: ListenableBuilder(
          listenable: Listenable.merge(
            <Listenable>[_focusNode, widget.controller],
          ),
          builder: (context, _) {
            return InputDecorator(
              decoration: widget.decoration,
              baseStyle: widget.style,
              textAlignVertical: TextAlignVertical.center,
              isFocused: _focusNode.hasFocus,
              isEmpty: widget.controller.text.isEmpty,
              child: EditableText(
                key: editableTextKey,
                controller: widget.controller,
                focusNode: _focusNode,
                style: widget.style,
                cursorColor: cursorColor,
                backgroundCursorColor: CupertinoColors.inactiveGray,
                selectionColor: _focusNode.hasFocus ? selectionColor : null,
                selectionControls: isApple
                    ? cupertinoTextSelectionHandleControls
                    : materialTextSelectionHandleControls,
                showSelectionHandles: _showSelectionHandles,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                textCapitalization: TextCapitalization.words,
            autocorrect: true,
            selectionHeightStyle: BoxHeightStyle.strut,
                rendererIgnoresPointer: true,
                paintCursorAboveText: isApple,
                cursorRadius: isApple ? const Radius.circular(2) : null,
                cursorOpacityAnimates: isApple,
                magnifierConfiguration:
                    TextMagnifier.adaptiveMagnifierConfiguration,
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
                onTapOutside: (_) => primaryFocus?.unfocus(),
                onSubmitted: (_) => widget.onSubmitted(),
                onChanged: widget.onChanged,
                onSelectionChanged: _handleSelectionChanged,
              ),
            );
          },
        ),
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
          showMapPlaceSearchModalSheet(
            context: context,
            ref: ref,
            keyword: keyword,
            mapController: mapController,
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
                autocorrect: true,
                textCapitalization: TextCapitalization.words,
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
        autocorrect: true,
        textCapitalization: TextCapitalization.sentences,
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
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
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
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
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
        ? defaultPostPriceCurrencyForLocale()
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
