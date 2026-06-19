import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/api/restaurant/repository/photo_nearby_restaurant_repository.dart';
import 'package:food_gram_app/core/model/photo_restaurant_candidate.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/screen/post/post_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 写真の撮影位置から近くのレストラン候補をダイアログで表示する
Future<void> showPhotoNearbyRestaurantDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String routerPath,
  required double latitude,
  required double longitude,
}) async {
  final vm = ref.read(postViewModelProvider().notifier);
  var handled = false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => Consumer(
      builder: (context, ref, _) {
        final t = Translations.of(context);
        final scheme = Theme.of(dialogContext).colorScheme;
        final candidatesAsync = ref.watch(
          photoNearbyRestaurantProvider(
            latitude: latitude,
            longitude: longitude,
          ),
        );

        return AlertDialog(
          backgroundColor: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            t.post.nearbySuggestionTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: candidatesAsync.when(
              loading: () => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const Gap(16),
                    Text(
                      t.map.loadingRestaurant,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              error: (_, __) {
                ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
                      name: AnalyticsEvent.postRestaurantAutoDetectFail,
                    );
                return Text(
                  t.post.nearbyFetchError,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                );
              },
              data: (candidates) {
                if (candidates.isEmpty) {
                  ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
                        name: AnalyticsEvent.postRestaurantAutoDetectFail,
                      );
                  return Text(
                    t.post.nearbyEmpty,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  );
                }
                ref.read(firebaseAnalyticsServiceProvider).logEventUnawaited(
                  name: AnalyticsEvent.postRestaurantAutoDetectSuccess,
                  parameters: {
                    AnalyticsParam.photoCount: candidates.length,
                  },
                );
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(dialogContext).size.height * 0.45,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: candidates.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final candidate = candidates[index];
                      final distance =
                          _formatDistance(t, candidate.distanceMeters);
                      final subtitle = _buildSubtitle(candidate, distance);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          candidate.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(subtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          handled = true;
                          Navigator.of(dialogContext).pop();
                          vm.selectNearbyCandidate(candidate);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          actions: candidatesAsync.isLoading
              ? null
              : [
                  TextButton(
                    onPressed: () async {
                      ref
                          .read(firebaseAnalyticsServiceProvider)
                          .logEventUnawaited(
                            name: AnalyticsEvent.postRestaurantManualSearch,
                          );
                      handled = true;
                      Navigator.of(dialogContext).pop();
                      vm.dismissNearbySuggestion();
                      if (!context.mounted) {
                        return;
                      }
                      final result = await context.pushNamed(routerPath);
                      if (result != null && context.mounted) {
                        vm.getPlace(result as Restaurant);
                      }
                    },
                    child: Text(t.post.nearbyManualSearch),
                  ),
                  TextButton(
                    onPressed: () {
                      handled = true;
                      Navigator.of(dialogContext).pop();
                      vm.postWithoutRestaurant();
                    },
                    child: Text(t.post.nearbyPostWithout),
                  ),
                ],
        );
      },
    ),
  );

  if (!handled && context.mounted) {
    final state = ref.read(postViewModelProvider());
    if (state.restaurant == PostViewModel.defaultRestaurantText &&
        !state.nearbySuggestionDismissed) {
      vm.dismissNearbySuggestion();
    }
  }
}

String _formatDistance(Translations t, double meters) {
  if (meters < 1000) {
    final label = meters < 100
        ? meters.toStringAsFixed(meters < 10 ? 1 : 0)
        : meters.round().toString();
    return t.post.nearbyDistanceMeters.replaceFirst('{distance}', label);
  }
  return t.post.nearbyDistanceKilometers.replaceFirst(
    '{distance}',
    (meters / 1000).toStringAsFixed(1),
  );
}

String _buildSubtitle(PhotoRestaurantCandidate candidate, String distance) {
  final parts = <String>[
    distance,
    if (candidate.rating != null) '★ ${candidate.rating!.toStringAsFixed(1)}',
  ];
  return parts.join(' · ');
}
