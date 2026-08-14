import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/api/restaurant/repository/google_restaurant_repository.dart';
import 'package:food_gram_app/core/api/restaurant/repository/kakao_restaurant_repository.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/theme/style/restaurant_style.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:food_gram_app/ui/component/common/app_tab_loading.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';

class RestaurantScreen extends HookConsumerWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    useEffect(
      () {
        ref
            .read(firebaseAnalyticsServiceProvider)
            .logEventUnawaited(name: AnalyticsEvent.restaurantOpen);
        return null;
      },
      const [],
    );
    final keyword = useState('');
    final isKakao = useState(false);
    final restaurant =
        ref.watch(googleRestaurantRepositoryProvider(keyword.value));
    final kakaoRestaurant =
        ref.watch(kakaoRestaurantRepositoryProvider(keyword.value));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.surface,
        actions: [
          TextButton(
            onPressed: () {
              isKakao.value = !isKakao.value;
            },
            child: Text(
              'Kakao検索:${isKakao.value ? 'ON' : 'OFF'}',
              style: TextStyle(
                color: isKakao.value ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ],
        leading: IconButton(
          onPressed: context.pop,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          // テキストフィールド以外をタップした時にキーボードを閉じる
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.restaurant.searchTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Gap(24),
                AppSearchTextField(
                  onSubmitted: (value) => keyword.value = value,
                ),
                const Gap(16),
                GestureDetector(
                  onTap: () {
                    const restaurant =
                        Restaurant(name: '不明', address: '', lat: 0, lng: 0);
                    primaryFocus?.unfocus();
                    context.pop(restaurant);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                        const Gap(4),
                        Text(
                          t.restaurant.unknownChip,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: keyword.value.isEmpty
                      ? _buildSearchEmptyState(context, t)
                      : AsyncValueSwitcher(
                          asyncValue:
                              isKakao.value ? kakaoRestaurant : restaurant,
                          errorType: TabLoadingType.map,
                          onErrorTap: () {
                            ref.invalidate(
                              googleRestaurantRepositoryProvider(keyword.value),
                            );
                            ref.invalidate(
                              kakaoRestaurantRepositoryProvider(keyword.value),
                            );
                          },
                          onData: (value) {
                            return value.isNotEmpty
                                ? ListView.builder(
                                    itemCount: value.length,
                                    itemBuilder: (context, index) {
                                      final restaurant = Restaurant(
                                        name: value[index].name,
                                        address: value[index].address,
                                        lat: value[index].lat,
                                        lng: value[index].lng,
                                      );
                                      return ListTile(
                                        onTap: () async {
                                          primaryFocus?.unfocus();
                                          // 現在のルートパスに基づいて適切なルート名を決定
                                          final currentPath =
                                              GoRouterState.of(context)
                                                  .uri
                                                  .path;
                                          final routeName = currentPath
                                                  .contains(
                                            RouterPath.timeLine,
                                          )
                                              ? RouterPath.restaurantMap
                                              : currentPath.contains(
                                                  RouterPath.mapDetailPost,
                                                )
                                                  ? RouterPath
                                                      .restaurantMapFromMap
                                                  : RouterPath
                                                      .restaurantMapMyProfile;
                                          final result = await context
                                              .pushNamed<Restaurant>(
                                            routeName,
                                            extra: restaurant,
                                          );
                                          // restaurantが返ってきたら、さらにPostScreenに戻す
                                          if (result != null &&
                                              context.mounted) {
                                            context.pop(result);
                                          }
                                        },
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                        title: Text(
                                          value[index].name,
                                          style: RestaurantStyle.name(context),
                                        ),
                                        subtitle: Text(
                                          value[index].address,
                                          style:
                                              RestaurantStyle.address(context),
                                        ),
                                      );
                                    },
                                  )
                                : const Center(child: AppSearchResultEmpty());
                          },
                        ),
                ),
                if (keyword.value.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildHintRow(
                          context,
                          Icons.location_on_outlined,
                          t.restaurant.hintsTitle,
                          Theme.of(context).colorScheme.primary,
                        ),
                        const Gap(12),
                        _buildHintRow(
                          context,
                          Icons.my_location_outlined,
                          t.restaurant.hintLocation,
                          Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        const Gap(8),
                        _buildHintRow(
                          context,
                          Icons.restaurant_outlined,
                          t.restaurant.hintCuisine,
                          Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchEmptyState(BuildContext context, Translations t) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 180,
                height: 180,
                child: Lottie.asset(
                  'assets/lottie/restaurant_search.json',
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                  options: LottieOptions(
                    enableMergePaths: true,
                  ),
                ),
              ),
            ],
          ),
          const Gap(4),
          Text(
            t.restaurant.emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintRow(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const Gap(8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
