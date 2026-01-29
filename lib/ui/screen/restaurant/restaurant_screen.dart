import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/api/restaurant/repository/google_restaurant_repository.dart';
import 'package:food_gram_app/core/api/restaurant/repository/kakao_restaurant_repository.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/theme/style/restaurant_style.dart';
import 'package:food_gram_app/i18n/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/component/common/app_async_value_group.dart';
import 'package:food_gram_app/ui/component/common/app_empty.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RestaurantScreen extends HookConsumerWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyword = useState('');
    final isKakao = useState(false);
    final restaurant =
        ref.watch(googleRestaurantRepositoryProvider(keyword.value));
    final kakaoRestaurant =
        ref.watch(kakaoRestaurantRepositoryProvider(keyword.value));
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Gap(5),
            AppSearchTextField(onSubmitted: (value) => keyword.value = value),
            const Gap(10),
            GestureDetector(
              onTap: () {
                const restaurant =
                    Restaurant(name: '不明', address: '', lat: 0, lng: 0);
                primaryFocus?.unfocus();
                context.pop(restaurant);
              },
              child: Chip(
                backgroundColor: Colors.white,
                label: Text(Translations.of(context).unknown),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
                avatar: const Icon(
                  Icons.restaurant_menu,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ),
            const Gap(10),
            Expanded(
              flex: 10,
              child: keyword.value.isEmpty
                  ? const AppSearchEmpty()
                  : AsyncValueSwitcher(
                      asyncValue: isKakao.value ? kakaoRestaurant : restaurant,
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
                                          GoRouterState.of(context).uri.path;
                                      final routeName = currentPath
                                              .contains(RouterPath.timeLine)
                                          ? RouterPath.restaurantMap
                                          : RouterPath.restaurantMapMyProfile;
                                      // pushNamed の結果を待つ
                                      final result =
                                          await context.pushNamed<Restaurant>(
                                        routeName,
                                        extra: restaurant,
                                      );
                                      // restaurantが返ってきたら、さらにPostScreenに戻す
                                      if (result != null && context.mounted) {
                                        context.pop(result);
                                      }
                                    },
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 20,
                                    ),
                                    title: Text(
                                      value[index].name,
                                      style: RestaurantStyle.name(),
                                    ),
                                    subtitle: Text(
                                      value[index].address,
                                      style: RestaurantStyle.address(),
                                    ),
                                  );
                                },
                              )
                            : const AppSearchResultEmpty();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
