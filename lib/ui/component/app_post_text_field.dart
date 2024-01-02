import 'package:flutter/material.dart';

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
