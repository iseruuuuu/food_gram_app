import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:gap/gap.dart';

class AppSearchTextField extends StatelessWidget {
  const AppSearchTextField({
    required this.onSubmitted,
    super.key,
  });

  final Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      contextMenuBuilder: (context, state) {
        if (SystemContextMenu.isSupported(context)) {
          return SystemContextMenu.editableText(editableTextState: state);
        }
        return AdaptiveTextSelectionToolbar.editableText(
          editableTextState: state,
        );
      },
      selectionHeightStyle: BoxHeightStyle.strut,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: const Icon(
            Icons.search,
            color: Colors.black,
          ),
        ),
        hintStyle: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: Colors.grey),
        label: Text(L10n.of(context).appRestaurantLabel),
        labelStyle: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black87),
        ),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      onSubmitted: onSubmitted,
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
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Gap(5),
          Icon(Icons.fastfood, color: Colors.black),
          Gap(10),
          Expanded(
            child: Semantics(
              label: 'postFoodField',
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
                    borderSide: BorderSide(color: Colors.black87),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: L10n.of(context).postFoodName,
                  label: Text(
                    L10n.of(context).postFoodNameInputField,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                controller: controller,
                autocorrect: false,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Semantics(
        label: 'postCommentField',
        child: TextField(
          contextMenuBuilder: (context, state) {
            if (SystemContextMenu.isSupported(context)) {
              return SystemContextMenu.editableText(editableTextState: state);
            }
            return AdaptiveTextSelectionToolbar.editableText(
              editableTextState: state,
            );
          },
          selectionHeightStyle: BoxHeightStyle.strut,
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black87),
            ),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            hintText: L10n.of(context).postCommentInputField,
            label: Text(
              L10n.of(context).postComment,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          controller: controller,
          maxLines: 6,
          autocorrect: false,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 15,
          ),
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
            : L10n.of(context).enterTheCorrectFormat,
        controller: controller,
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: L10n.of(context).email,
          labelStyle: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold, color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
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
          SizedBox(width: 10),
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
                  hintText: L10n.of(context).userName,
                  label: Text(
                    L10n.of(context).userNameInputField,
                    style: TextStyle(color: Colors.grey),
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
                  hintText: L10n.of(context).editBioInputField,
                  label: Text(
                    L10n.of(context).editBio,
                    style: TextStyle(color: Colors.grey),
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
          Gap(10),
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
                  hintText: L10n.of(context).userId,
                  label: Text(
                    L10n.of(context).userIdInputField,
                    style: TextStyle(color: Colors.grey),
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
