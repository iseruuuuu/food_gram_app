import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/api/restaurant/services/google_restaurant_service.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/common/app_error_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MapPlaceSearchModalSheet extends HookConsumerWidget {
  const MapPlaceSearchModalSheet({
    required this.initialQuery,
    required this.onRestaurantSelected,
    super.key,
  });

  final String initialQuery;
  final Future<void> Function(Restaurant restaurant) onRestaurantSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchQuery = useState<String>(initialQuery.trim());
    final restaurantsAsync =
        ref.watch(googleRestaurantServicesProvider(searchQuery.value));
    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: AppSearchTextField(
                initialText: initialQuery.trim(),
                onSubmitted: (value) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  searchQuery.value = value.trim();
                },
              ),
            ),
            Expanded(
              child: restaurantsAsync.when(
                data: (value) {
                  final list = value.take(10).toList();
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          t.search.emptyResult,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final restaurant = list[index];
                      return ListTile(
                        title: Text(
                          restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          restaurant.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () async {
                          await onRestaurantSelected(restaurant);
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stackTrace) => SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AppErrorWidget(
                      onTap: () {
                        ref.invalidate(
                          googleRestaurantServicesProvider(searchQuery.value),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
