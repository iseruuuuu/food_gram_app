import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:gap/gap.dart';

class AppSearchTextField extends StatelessWidget {
  const AppSearchTextField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(128),
          ),
        ),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        autocorrect: false,
        onChanged: onChanged,
      ),
    );
  }
}

class AppPostTextField extends StatelessWidget {
  const AppPostTextField({
    required this.controller,
    required this.hintText,
    required this.maxLines,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '食べたもの',
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Semantics(
              label: 'postFoodField',
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '食べたもの',
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

class AppPostCommentTextField extends StatelessWidget {
  const AppPostCommentTextField({
    required this.controller,
    required this.hintText,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: const SizedBox(
              width: 80,
              child: Text(
                'コメント',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Semantics(
              label: 'postCommentField',
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'コメント',
                ),
                controller: controller,
                maxLines: 8,
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

class AppAuthTextField extends StatelessWidget {
  const AppAuthTextField({
    required this.controller,
    required this.hintText,
    required this.maxLines,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        autocorrect: false,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 17,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.all(15),
          focusedBorder: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(),
          alignLabelWithHint: true,
          labelText: hintText,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 17,
          ),
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          SizedBox(width: 10),
          Expanded(
            child: Semantics(
              label: 'nameField',
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: L10n.of(context).user_name_text_field,
                  label: Text(
                    L10n.of(context).user_name,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                controller: controller,
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
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: const SizedBox(
              width: 80,
              child: Text(
                '自己紹介',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              label: 'selfIntroductionField',
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '自己紹介',
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
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: L10n.of(context).user_id_text_field,
                  label: Text(
                    L10n.of(context).user_id,
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
