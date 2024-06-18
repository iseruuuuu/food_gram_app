import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/data/api/mapbox_restaurant_api.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/utils/async_value_group.dart';
import 'package:food_gram_app/ui/component/app_empty.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RestaurantScreen extends HookConsumerWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyword = useState('');
    final restaurant = ref.watch(mapboxRestaurantApiProvider(keyword.value));
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.white),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            AppSearchTextField(onSubmitted: (value) => keyword.value = value),
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    final restaurant =
                        Restaurant(name: '自炊', address: '', lat: 0, lng: 0);
                    primaryFocus?.unfocus();
                    context.pop(restaurant);
                  },
                  child: Chip(
                    label: const Text('自炊'),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    avatar: const Icon(
                      Icons.home,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final restaurant =
                        Restaurant(name: '不明', address: '', lat: 0, lng: 0);
                    primaryFocus?.unfocus();
                    context.pop(restaurant);
                  },
                  child: Chip(
                    label: const Text('不明・ヒットなし'),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    avatar: const Icon(
                      Icons.restaurant_menu,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
            Expanded(
              flex: 10,
              child: AsyncValueSwitcher(
                asyncValue: restaurant,
                onData: (value) {
                  return value.isNotEmpty
                      ? ListView.builder(
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                final restaurant = Restaurant(
                                  name: value[index].name,
                                  address: value[index].address,
                                  lat: value[index].lat,
                                  lng: value[index].lng,
                                );
                                primaryFocus?.unfocus();
                                context.pop(restaurant);
                              },
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 20),
                              title: Text(
                                value[index].name,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                value[index].address,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          },
                        )
                      : const AppSearchEmpty();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
