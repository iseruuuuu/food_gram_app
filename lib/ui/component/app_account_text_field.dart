import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppNameTextField extends StatelessWidget {
  const AppNameTextField({
    required this.title,
    required this.controller,
    super.key,
  });

  final String title;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Semantics(
              label: 'nameField',
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '名前',
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
          SizedBox(
            width: 80,
            child: Text(
              'ユーザーID',
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Semantics(
              label: 'userNameField',
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'ユーザーID',
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
