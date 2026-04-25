import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/services/user_service.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/map/record_japan_world_map_scene.dart';
import 'package:food_gram_app/ui/component/map/record_map_layout.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_detail_scroll_view.dart';
import 'package:food_gram_app/ui/screen/record/record_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class RecordScreen extends HookConsumerWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordViewModelProvider);
    final controller = ref.watch(recordViewModelProvider.notifier);
    final location = ref.watch(locationProvider);
    final mapService = ref.watch(myMapRepositoryProvider);
    final isTapPin = useState(false);
    final post = useState<List<Posts?>>([]);
    final isEarthStyle = useState(false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          AsyncValueSwitcher(
            asyncValue: AsyncValueGroup.group2(location, mapService),
            onErrorTap: () {
              ref
                ..invalidate(locationProvider)
                ..invalidate(myMapRepositoryProvider);
            },
            onData: (value) {
              if (state.viewType == MapViewType.detail) {
                return RecordDetailScrollView(posts: value.$2);
              }
              final isLocationEnabled =
                  value.$1.latitude != 0 && value.$1.longitude != 0;
              return RecordJapanWorldMapScene(
                initialTarget: isLocationEnabled
                    ? LatLng(value.$1.latitude, value.$1.longitude)
                    : recordMapDefaultLocation,
                styleString: recordMapLocalizedStyleAsset(
                  context,
                  isEarthStyle: isEarthStyle.value,
                ),
                onMapCreated: (mapLibre) {
                  controller.setMapController(
                    mapLibre,
                    onPinTap: (posts) {
                      isTapPin.value = true;
                      post.value = posts;
                    },
                    iconSize: recordMapIconSizeForContext(context),
                  );
                },
                onMapBackgroundTap: () => isTapPin.value = false,
                onStyleLoaded: controller.onStyleLoaded,
                isTapPin: isTapPin.value,
                post: post.value,
                viewType: state.viewType,
                onViewTypeChanged: controller.changeViewType,
                postsCount: state.postsCount,
                visitedPrefecturesCount: state.visitedPrefecturesCount,
                visitedCountriesCount: state.visitedCountriesCount,
                visitedAreasCount: state.visitedAreasCount,
                activityDays: state.activityDays,
                postingStreakWeeks: state.postingStreakWeeks,
                onResetBearing: controller.resetBearing,
              );
            },
          ),
          AppMapLoading(loading: state.isLoading, hasError: state.hasError),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          heroTag: null,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 10,
          shape: CircleBorder(
            side: BorderSide(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          onPressed: () async {
            await context
                .pushNamed(RouterPath.timeLinePost)
                .then((value) async {
              if (value != null) {
                ref.invalidate(myMapRepositoryProvider);
                final uid = ref.read(currentUserProvider);
                if (uid != null) {
                  ref
                      .read(userServiceProvider.notifier)
                      .invalidateUserCache(uid);
                }
              }
            });
          },
          child: const Icon(Icons.add, size: 35),
        ),
      ),
    );
  }
}
