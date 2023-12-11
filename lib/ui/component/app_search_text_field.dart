import 'package:flutter/material.dart';

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
