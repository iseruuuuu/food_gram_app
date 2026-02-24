import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

typedef OnSubmitted = void Function(String value);

class AppSearchTextField extends HookWidget {
  const AppSearchTextField({
    required this.onSubmitted,
    super.key,
  });

  final OnSubmitted? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final searchText = useState('');
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
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
              style: TextStyle(color: scheme.onSurface),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    Icons.search,
                    color: scheme.onSurface,
                  ),
                ),
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: scheme.onSurfaceVariant),
                label: Text(Translations.of(context).app.restaurantLabel),
                labelStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: scheme.onSurface),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  borderSide: BorderSide(
                    color: AppTheme.primaryBlue,
                    width: 2,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  borderSide: BorderSide(
                    color: AppTheme.primaryBlue,
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              autocorrect: false,
              onSubmitted: (_) {
                onSubmitted!(searchText.value);
              },
              onChanged: (text) {
                searchText.value = text;
              },
            ),
          ),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.zero,
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : AppTheme.primaryBlue,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
              onPressed: () {
                primaryFocus?.unfocus();
                onSubmitted!(searchText.value);
              },
              child: Text(
                Translations.of(context).search.button,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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
