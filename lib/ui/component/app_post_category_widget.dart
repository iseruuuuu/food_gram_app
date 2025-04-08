import 'package:flutter/material.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_post_category_modal_sheet.dart';

class AppPostCountryCategoryWidget extends StatelessWidget {
  const AppPostCountryCategoryWidget({
    required this.tag,
    required this.title,
    super.key,
  });

  final ValueNotifier<String> tag;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (context) {
            return AppPostCountryCategoryModalSheet(
              onChanged: (value) {
                tag.value = value;
              },
              tagValue: tag.value,
            );
          },
        );
      },
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            tag.value.isNotEmpty ? tag.value : title,
            style: TextStyle(
              fontSize: tag.value.isNotEmpty ? 30 : 18,
            ),
          ),
        ),
      ),
    );
  }
}

class AppPostFoodCategoryWidget extends StatelessWidget {
  const AppPostFoodCategoryWidget({
    required this.tag,
    required this.title,
    super.key,
  });

  final ValueNotifier<String> tag;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (context) {
            return AppPostFoodCategoryModalSheet(
              onChanged: (value) {
                tag.value = value;
              },
              tagValue: tag.value,
            );
          },
        );
      },
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            tag.value.isNotEmpty ? tag.value : title,
            style: TextStyle(
              fontSize: tag.value.isNotEmpty ? 30 : 18,
            ),
          ),
        ),
      ),
    );
  }
}
