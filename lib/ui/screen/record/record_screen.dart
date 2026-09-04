import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/map_view_type.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/core/utils/provider/location.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/common/app_tab_loading.dart';
import 'package:food_gram_app/ui/screen/record/components/detail/record_detail_screen.dart';
import 'package:food_gram_app/ui/screen/record/components/japan/record_japan_screen.dart';
import 'package:food_gram_app/ui/screen/record/components/world/record_world_screen.dart';
import 'package:food_gram_app/ui/screen/record/record_view_model.dart';
import 'package:food_gram_app/ui/screen/tab/tab_state.dart';
import 'package:food_gram_app/ui/screen/tab/use_scroll_to_top_on_tab_trigger.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RecordScreen extends HookConsumerWidget {
  const RecordScreen({super.key});

  static const int _tabIndex = TabIndex.myMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recordViewModelProvider);
    final location = ref.watch(locationProvider);
    final mapService = ref.watch(myMapRepositoryProvider);
    final scrollController = useScrollController();
    useEffect(
      () {
        unawaited(CountryDetector.ensureLoaded());
        return null;
      },
      const [],
    );
    useScrollToTopOnTabTrigger(
      ref: ref,
      scrollController: scrollController,
      tabIndex: _tabIndex,
    );
    return Scaffold(
      body: Stack(
        children: [
          AsyncValueSwitcher(
            asyncValue: AsyncValueGroup.group2(location, mapService),
            onLoading: const AppTabLoading.record(),
            errorType: TabLoadingType.record,
            onErrorTap: () {
              ref
                ..invalidate(locationProvider)
                ..invalidate(myMapRepositoryProvider);
            },
            onData: (value) {
              if (state.viewType == MapViewType.detail) {
                return RecordDetailScreen(
                  posts: value.$2,
                  scrollController: scrollController,
                );
              }
              if (state.viewType == MapViewType.world) {
                return RecordWorldScreen(posts: value.$2);
              }
              return RecordJapanScreen(
                posts: value.$2,
                scrollController: scrollController,
              );
            },
          ),
          AppMapLoading(loading: state.isLoading, hasError: state.hasError),
        ],
      ),
    );
  }
}
