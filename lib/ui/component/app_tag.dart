import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

typedef OnTagSelected = void Function(List<String> tags);

class AppFoodTag extends HookWidget {
  const AppFoodTag({
    required this.onTagSelected,
    required this.foodTags,
    required this.foodTexts,
    super.key,
  });

  final OnTagSelected onTagSelected;
  final List<String> foodTags;
  final ValueNotifier<List<String>> foodTexts;

  Future<void> _showTagSelector(
    BuildContext context,
    ValueNotifier<List<String>> foodTexts,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HookBuilder(
        builder: (context) {
          final selectedTags = useState<List<String>>(foodTags);
          final selectedTexts = useState<List<String>>(foodTexts.value);
          return Container(
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
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: context.pop,
                        child: Text(
                          L10n.of(context).cancel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        L10n.of(context).selectFoodTag,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          onTagSelected(selectedTags.value);
                          foodTexts.value = selectedTexts.value;
                          context.pop();
                        },
                        child: Text(
                          L10n.of(context).save,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0168B7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: foodCategory.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                getLocalizedCategoryName(entry.key, context),
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
                                final text =
                                    getLocalizedFoodName(food[0], context);
                                final isSelected =
                                    selectedTags.value.contains(emoji);
                                return GestureDetector(
                                  onTap: () {
                                    final newSelectedTags = <String>[
                                      ...selectedTags.value,
                                    ];
                                    final newSelectedTexts = <String>[
                                      ...selectedTexts.value,
                                    ];
                                    if (isSelected) {
                                      newSelectedTags.remove(emoji);
                                      newSelectedTexts.remove(text);
                                    } else {
                                      newSelectedTags.add(emoji);
                                      newSelectedTexts.add(text);
                                    }
                                    selectedTags.value = newSelectedTags;
                                    selectedTexts.value = newSelectedTexts;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.white,
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
                                          text,
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
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    useValueListenable(foodTexts);
    return GestureDetector(
      onTap: () => _showTagSelector(context, foodTexts),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    const Gap(16),
                    Expanded(
                      child: foodTags.isEmpty
                          ? Text(
                              L10n.of(context).selectFoodTag,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            )
                          : Row(
                              children: [
                                if (foodTags.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            Colors.blue.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          foodTags.first,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const Gap(2),
                                        Text(
                                          getLocalizedFoodName(
                                            foodTags.first,
                                            context,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0168B7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (foodTags.length > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.blue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            foodTags[1],
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                          const Gap(2),
                                          Text(
                                            getLocalizedFoodName(
                                              foodTags[1],
                                              context,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0168B7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (foodTags.length > 2)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      '+${foodTags.length - 2}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0168B7),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    if (foodTags.isEmpty)
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

  final void Function(String) onTagSelected;
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
      builder: (context) => HookBuilder(
        builder: (context) {
          final selectedTag = useState<String>(countryTag);
          final selectedText = useState<String>(countryText.value);
          return Container(
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
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: context.pop,
                        child: Text(
                          L10n.of(context).cancel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        L10n.of(context).selectCountryTag,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          onTagSelected(selectedTag.value);
                          countryText.value = selectedText.value;
                          context.pop();
                        },
                        child: Text(
                          L10n.of(context).save,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0168B7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildCountryTagItems(
                        context,
                        selectedTag.value,
                        selectedText.value,
                        (tag, text) {
                          selectedTag.value = tag;
                          selectedText.value = text;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCountryTagItems(
    BuildContext context,
    String selectedTag,
    String selectedText,
    void Function(String, String) onSelectionChanged,
  ) {
    return [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: countryCategory.entries.map((entry) {
          final isSelected = selectedTag == entry.key;
          return GestureDetector(
            onTap: () {
              final countryName = getLocalizedCountryName(entry.key, context);
              onSelectionChanged(entry.key, countryName);
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
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                ),
              ),
              child: FittedBox(
                child: Row(
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      getLocalizedCountryName(entry.key, context),
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    useValueListenable(countryText);
    return GestureDetector(
      onTap: () => _showTagSelector(context, countryText),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    const Gap(16),
                    Expanded(
                      child: countryTag.isEmpty
                          ? Text(
                              L10n.of(context).selectCountryTag,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            )
                          : Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        countryTag,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const Gap(2),
                                      Text(
                                        getLocalizedCountryName(
                                          countryTag,
                                          context,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0168B7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                    if (countryTag.isEmpty)
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
            ],
          ),
        ),
      ),
    );
  }
}
