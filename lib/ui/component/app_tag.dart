import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/tag.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

typedef OnTagSelected = void Function(String tag);

class AppFoodTag extends HookWidget {
  const AppFoodTag({
    required this.selectedTags,
    required this.onTagSelected,
    required this.favoriteTagText,
    super.key,
  });

  final String selectedTags;
  final OnTagSelected onTagSelected;
  final String favoriteTagText;

  Future<void> _showTagSelector(
    BuildContext context,
    ValueNotifier<String> selectedCategoryName,
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
                    favoriteTagText,
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
                              final isSelected = selectedTags.contains(emoji);
                              return GestureDetector(
                                onTap: () {
                                  onTagSelected(emoji);
                                  selectedCategoryName.value = text;
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
    final foodLabel = useState('');
    return GestureDetector(
      onTap: () => _showTagSelector(context, foodLabel),
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
                (selectedTags != '') ? selectedTags : favoriteTagText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: (selectedTags != '') ? Colors.black : Colors.grey,
                ),
              ),
              const Gap(8),
              Text(
                (foodLabel.value != '') ? foodLabel.value : '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: (selectedTags != '') ? Colors.black : Colors.grey,
                ),
              ),
              const Spacer(),
              if (selectedTags == '')
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
    required this.selectedTags,
    required this.onTagSelected,
    super.key,
  });

  final String selectedTags;
  final OnTagSelected onTagSelected;

  Future<void> _showTagSelector(
    BuildContext context,
    ValueNotifier<String> selectedCategoryName,
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
                    onPressed: () => context.pop,
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
                  children: countryCategory.entries.map((entry) {
                    final isSelected = selectedTags.contains(entry.key);
                    return GestureDetector(
                      onTap: () {
                        onTagSelected(entry.key);
                        selectedCategoryName.value = entry.value;
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
                  }).toList(),
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
    final countryLabel = useState('');
    return GestureDetector(
      onTap: () => _showTagSelector(context, countryLabel),
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
                (selectedTags != '')
                    ? selectedTags
                    : L10n.of(context).selectCountryTag,
                style: TextStyle(
                  fontSize: (selectedTags != '') ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: (selectedTags != '') ? Colors.black : Colors.grey,
                ),
              ),
              const Gap(8),
              Text(
                (countryLabel.value != '') ? countryLabel.value : '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: (selectedTags != '') ? Colors.black : Colors.grey,
                ),
              ),
              const Spacer(),
              if (selectedTags == '')
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
