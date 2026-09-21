import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/supabase/post/repository/map_post_repository.dart';
import 'package:food_gram_app/core/utils/location/country_detector.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/keep_alive_page_view.dart';
import 'package:food_gram_app/ui/component/loading/app_overlay_loading.dart';
import 'package:food_gram_app/ui/component/loading/app_tab_loading.dart';
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
            asyncValue: mapService,
            onLoading: const AppTabLoading.record(),
            errorType: TabLoadingType.record,
            onErrorTap: () {
              ref.invalidate(myMapRepositoryProvider);
            },
            onData: (posts) {
              return KeepAlivePageView(
                index: state.viewType.index,
                children: [
                  RecordDetailScreen(
                    posts: posts,
                    scrollController: scrollController,
                  ),
                  RecordJapanScreen(posts: posts),
                  RecordWorldScreen(posts: posts),
                ],
              );
            },
          ),
          AppProcessLoading(
            loading: state.isLoading,
            status: state.hasError
                ? Translations.of(context).map.loadingError
                : Translations.of(context).map.loadingRestaurant,
          ),
        ],
      ),
    );
  }
}
