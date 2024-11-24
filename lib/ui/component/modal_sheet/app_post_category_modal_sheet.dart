import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class AppPostCategoryModalSheet extends ConsumerWidget {
  const AppPostCategoryModalSheet({
    required this.category,
    required this.onChanged,
    required this.tagValue,
    super.key,
  });

  final List<String> category;
  final Function(String) onChanged;
  final String tagValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Gap(10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: category.map<Widget>((data) {
                  return FilterChip(
                    showCheckmark: false,
                    backgroundColor: Colors.white,
                    label: Text(
                      data,
                      style: TextStyle(fontSize: 30),
                    ),
                    selected: tagValue == data,
                    selectedColor: Colors.greenAccent,
                    onSelected: (value) {
                      onChanged(data);
                      context.pop();
                    },
                  );
                }).toList(),
              ),
              Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
