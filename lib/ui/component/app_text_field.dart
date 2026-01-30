import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                ),
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.grey),
                label: Text(Translations.of(context).app.restaurantLabel),
                labelStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.black),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  borderSide: BorderSide(
                    color: Colors.blueAccent,
                    width: 2,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  borderSide: BorderSide(
                    color: Colors.blueAccent,
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
                foregroundColor: Colors.blueAccent,
                backgroundColor: Colors.blueAccent,
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
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          const Gap(5),
          const Icon(
            Icons.fastfood,
            color: Colors.black,
            size: 28,
          ),
          const Gap(10),
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
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black87),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(6),
                ),
                label: Text(Translations.of(context).post.foodNameInputField),
                labelStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              controller: controller,
              keyboardType: TextInputType.text,
              autocorrect: false,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 15,
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
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
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black87),
            borderRadius: BorderRadius.circular(6),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(6),
          ),
          label: Text(
            Translations.of(context).post.comment,
          ),
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        controller: controller,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        maxLines: 6,
        autocorrect: false,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 15,
        ),
      ),
    );
  }
}

class AppAuthTextField extends StatelessWidget {
  const AppAuthTextField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: TextFormField(
        contextMenuBuilder: (context, state) {
          if (SystemContextMenu.isSupported(context)) {
            return SystemContextMenu.editableText(editableTextState: state);
          }
          return AdaptiveTextSelectionToolbar.editableText(
            editableTextState: state,
          );
        },
        selectionHeightStyle: BoxHeightStyle.strut,
        onTap: ScaffoldMessenger.of(context).hideCurrentSnackBar,
        autovalidateMode: AutovalidateMode.always,
        validator: (value) => value!.isValidEmail() || value.isEmpty
            ? null
            : Translations.of(context).enterTheCorrectFormat,
        controller: controller,
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: Translations.of(context).email,
          labelStyle: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold, color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black87),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}

extension StringEx on String {
  bool isValidEmail() {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              label: 'nameField',
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
                  hintText: Translations.of(context).userName,
                  label: Text(
                    Translations.of(context).userNameInputField,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                controller: controller,
                autocorrect: false,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              label: 'selfIntroductionField',
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
                  hintText: Translations.of(context).edit.bioInputField,
                  label: Text(
                    Translations.of(context).edit.bio,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                controller: controller,
                maxLines: 5,
                autocorrect: false,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 17,
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          const Gap(10),
          Expanded(
            child: Semantics(
              label: 'userNameField',
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
                  hintText: Translations.of(context).userId,
                  label: Text(
                    Translations.of(context).userIdInputField,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                controller: controller,
                autocorrect: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp('[a-zA-Z0-9@_.-]'),
                  ),
                ],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
