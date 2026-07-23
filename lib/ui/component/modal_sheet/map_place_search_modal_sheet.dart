import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_screen.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/api/restaurant/services/google_restaurant_service.dart';
import 'package:food_gram_app/core/local/providers/want_to_go_notifier.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/restaurant_group.dart';
import 'package:food_gram_app/core/model/want_to_go_item.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/common/app_tab_error.dart';
import 'package:food_gram_app/ui/component/modal_sheet/map_restaurant_overview_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/map/map_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> showMapPlaceSearchModalSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String keyword,
  required MapViewModel mapController,
}) async {
  ref.read(firebaseAnalyticsServiceProvider).logScreen(AnalyticsScreen.search);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.of(sheetContext).size.height * 0.8,
      child: MapPlaceSearchModalSheet(
        initialQuery: keyword,
        onRestaurantSelected: (restaurant) async {
          final postsResult = await ref
              .read(mapPostRepositoryProvider.notifier)
              .getRestaurantPosts(
                lat: restaurant.lat,
                lng: restaurant.lng,
              );
          final hasPostsOrNull = postsResult.when(
            success: (posts) => posts.isNotEmpty,
            failure: (_) => null,
          );
          if (hasPostsOrNull == null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('投稿の取得に失敗しました。もう一度お試しください。'),
                ),
              );
            }
            return;
          }
          final hasPosts = hasPostsOrNull;
          await mapController.animateToLatLng(
            lat: restaurant.lat,
            lng: restaurant.lng,
          );
          mapController.setNearbySearchCenterFromLatLng(
            lat: restaurant.lat,
            lng: restaurant.lng,
          );
          ref.read(mapModalSelectionProvider.notifier).state =
              MapModalSelection(
            name: restaurant.name,
            lat: restaurant.lat,
            lng: restaurant.lng,
            placeSearchRestaurant: restaurant,
          );
          if (hasPosts) {
            await mapController.clearSearchResultPin();
          } else {
            await mapController.setSearchResultPin(
              restaurant.lat,
              restaurant.lng,
            );
          }
        },
      ),
    ),
  );
}

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
    final wantToGoList =
        ref.watch(wantToGoNotifierProvider).valueOrNull ??
            const <WantToGoItem>[];
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
                  final trimmed = value.trim();
                  searchQuery.value = trimmed;
                  if (trimmed.isNotEmpty) {
                    ref
                        .read(firebaseAnalyticsServiceProvider)
                        .logMapSearch(trimmed);
                  }
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
                      final isInList =
                          wantToGoList.any((e) => e.name == restaurant.name);
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
                        trailing: IconButton(
                          tooltip: isInList
                              ? t.wantToGo.removeFromList
                              : t.wantToGo.addToList,
                          icon: Icon(
                            isInList
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isInList
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          onPressed: () async {
                            final added = await ref
                                .read(wantToGoNotifierProvider.notifier)
                                .toggle(restaurant);
                            if (!context.mounted) {
                              return;
                            }
                            SnackBarHelper().openSuccessSnackBar(
                              context,
                              added
                                  ? t.wantToGo.added
                                  : t.wantToGo.removed,
                              '',
                            );
                          },
                        ),
                        onTap: () async {
                          unawaited(
                            ref
                                .read(firebaseAnalyticsServiceProvider)
                                .logMapSearchResultTap(searchQuery.value),
                          );
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
                    child: AppTabError.map(
                      compact: true,
                      onRetry: () {
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
