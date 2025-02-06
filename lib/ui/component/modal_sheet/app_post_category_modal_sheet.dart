import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class AppPostCountryCategoryModalSheet extends ConsumerWidget {
  const AppPostCountryCategoryModalSheet({
    required this.onChanged,
    required this.tagValue,
    super.key,
  });

  final Function(String) onChanged;
  final String tagValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(4),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: countryCategory.map<Widget>((data) {
                return GestureDetector(
                  onTap: () {
                    onChanged(data);
                    context.pop();
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: tagValue == data ? Colors.blue : Colors.grey,
                        width: tagValue == data ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        data,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}

class AppPostFoodCategoryModalSheet extends StatelessWidget {
  const AppPostFoodCategoryModalSheet({
    required this.onChanged,
    required this.tagValue,
    super.key,
  });

  final Function(String) onChanged;
  final String tagValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(4),
            ...foodCategory.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: entry.value.map((emoji) {
                      return GestureDetector(
                        onTap: () {
                          onChanged(emoji);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  tagValue == emoji ? Colors.blue : Colors.grey,
                              width: tagValue == emoji ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 36),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }).toList(),
            Gap(16),
          ],
        ),
      ),
    );
  }
}
