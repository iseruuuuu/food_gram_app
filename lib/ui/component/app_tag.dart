import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

typedef OnTagSelected = void Function(String tag);

class AppFoodTag extends HookWidget {
  const AppFoodTag({
    required this.onTagSelected,
    required this.foodTag,
    required this.foodText,
    super.key,
  });

  final OnTagSelected onTagSelected;
  final String foodTag;
  final ValueNotifier<String> foodText;

  Future<void> _showTagSelector(
    BuildContext context,
    ValueNotifier<String> foodText,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    L10n.of(context).selectFoodTag,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: context.pop,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...foodCategory.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: entry.value.map((food) {
                              final emoji = food[0];
                              final text = food[1];
                              final isSelected = foodTag.contains(emoji);
                              return GestureDetector(
                                onTap: () {
                                  onTagSelected(emoji);
                                  foodText.value = text;
                                  context.pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected ? Colors.blue : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const Gap(4),
                                      Text(
                                        food[1],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentFoodText = useValueListenable(foodText);
    return GestureDetector(
      onTap: () => _showTagSelector(context, foodText),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Gap(16),
              Text(
                (foodTag != '') ? foodTag : L10n.of(context).selectFoodTag,
                style: TextStyle(
                  fontSize: (foodTag != '') ? 24 : 16,
                  fontWeight: FontWeight.bold,
                  color: (foodTag != '') ? Colors.black : Colors.grey,
                ),
              ),
              const Gap(8),
              Text(
                (currentFoodText != '') ? currentFoodText : '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: (foodTag != '') ? Colors.black : Colors.grey,
                ),
              ),
              const Spacer(),
              if (foodTag == '')
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.chevron_right,
                    size: 30,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppCountryTag extends HookWidget {
  const AppCountryTag({
    required this.onTagSelected,
    required this.countryTag,
    required this.countryText,
    super.key,
  });

  final OnTagSelected onTagSelected;
  final String countryTag;
  final ValueNotifier<String> countryText;

  Future<void> _showTagSelector(
    BuildContext context,
    ValueNotifier<String> countryText,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    L10n.of(context).selectCountryTag,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: context.pop,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...countryCategory.entries.map((entry) {
                      final isSelected = countryTag.contains(entry.key);
                      return GestureDetector(
                        onTap: () {
                          onTagSelected(entry.key);
                          countryText.value = entry.value;
                          context.pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  isSelected ? Colors.blue : Colors.grey[300]!,
                            ),
                          ),
                          child: FittedBox(
                            child: Row(
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCountryText = useValueListenable(countryText);
    return GestureDetector(
      onTap: () => _showTagSelector(context, countryText),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              const Gap(16),
              Text(
                (countryTag != '')
                    ? countryTag
                    : L10n.of(context).selectCountryTag,
                style: TextStyle(
                  fontSize: (countryTag != '') ? 24 : 16,
                  fontWeight: FontWeight.bold,
                  color: (countryTag != '') ? Colors.black : Colors.grey,
                ),
              ),
              const Gap(8),
              Text(
                (currentCountryText != '') ? currentCountryText : '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: (countryTag != '') ? Colors.black : Colors.grey,
                ),
              ),
              const Spacer(),
              if (countryTag == '')
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.chevron_right,
                    size: 30,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
