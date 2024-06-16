import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/data/api/mapbox_restaurant_api.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/ui/component/app_empty.dart';
import 'package:food_gram_app/ui/component/app_error_widget.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RestaurantScreen extends HookConsumerWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyword = useState('');
    final restaurant = ref.watch(mapboxRestaurantApiProvider(keyword.value));
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.white),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            AppSearchTextField(onChanged: (value) => keyword.value = value),
            const Gap(10),
            Flex(
              direction: Axis.horizontal,
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
                    label: Text('自炊'),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    avatar: Icon(
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
                    label: Text('不明・ヒットなし'),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    avatar: Icon(
                      Icons.restaurant_menu,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(10),
            restaurant.when(
              data: (value) {
                return Expanded(
                  child: value.isNotEmpty
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
                              trailing: Icon(Icons.arrow_forward_ios, size: 20),
                              title: Text(
                                value[index].name,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                value[index].address,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          },
                        )
                      : AppSearchEmpty(),
                );
              },
              error: (_, __) {
                return AppErrorWidget(onTap: () => context.pop());
              },
              loading: () => Expanded(
                child: Center(
                  child: LoadingAnimationWidget.dotsTriangle(
                    color: Colors.deepPurple,
                    size: 50,
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
