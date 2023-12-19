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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: TextField(
        controller: controller,
        maxLines: 7,
        autocorrect: false,
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
