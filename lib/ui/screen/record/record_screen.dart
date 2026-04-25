import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/supabase/user/services/user_service.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_detail_screen.dart';
import 'package:food_gram_app/ui/screen/record/components/map/record_map.dart';
import 'package:food_gram_app/ui/screen/record/record_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordViewModelProvider);
    final controller = ref.watch(recordViewModelProvider.notifier);
    final location = ref.watch(locationProvider);
    final mapService = ref.watch(myMapRepositoryProvider);
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
                return RecordDetailScreen(posts: value.$2);
              }
              return RecordMap(
                state: state,
                controller: controller,
                latitude: value.$1.latitude,
                longitude: value.$1.longitude,
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
