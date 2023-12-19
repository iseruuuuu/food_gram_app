import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/model/restaurant.dart';
import 'package:food_gram_app/ui/component/app_request.dart';
import 'package:food_gram_app/ui/component/app_search_text_field.dart';
import 'package:food_gram_app/ui/screen/post/restaurant_view_model.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RestaurantScreen extends ConsumerWidget {
  const RestaurantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(restaurantViewModelProvider().notifier);
    final state = ref.watch(restaurantViewModelProvider());
    final loading = ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        body: state.isApproval
            ? Column(
                children: [
                  AppSearchTextField(
                    controller: controller.controller,
                    hintText: 'レストランを検索',
                    onChanged: controller.search,
                  ),
                  GestureDetector(
                    onTap: () {
                      final restaurant = Restaurant(
                        restaurant: '自炊',
                        lat: 0,
                        lng: 0,
                      );
                      primaryFocus?.unfocus();
                      context.pop(restaurant);
                    },
                    child: ListTile(
                      leading: Icon(Icons.home),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                      ),
                      title: Text(
                        '自炊',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final restaurant = Restaurant(
                        restaurant: '不明',
                        lat: 0,
                        lng: 0,
                      );
                      primaryFocus?.unfocus();
                      context.pop(restaurant);
                    },
                    child: ListTile(
                      leading: Icon(Icons.restaurant_menu),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                      ),
                      title: Text(
                        'レストラン名が不明orヒットしない',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!loading)
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.restaurant.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              final restaurant = Restaurant(
                                restaurant: state.restaurant[index],
                                lat: state.lat[index],
                                lng: state.log[index],
                              );
                              primaryFocus?.unfocus();
                              context.pop(restaurant);
                            },
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                            ),
                            title: Text(
                              state.restaurant[index],
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              state.address[index],
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        children: [
                          Spacer(),
                          Center(
                            child: LoadingAnimationWidget.dotsTriangle(
                              color: Colors.deepPurple,
                              size: 50,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                ],
              )
            : AppRequest(),
      ),
    );
  }
}
