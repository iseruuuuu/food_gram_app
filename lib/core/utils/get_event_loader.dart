import 'dart:collection';

import 'package:food_gram_app/core/model/posts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:table_calendar/table_calendar.dart';

part 'get_event_loader.g.dart';

@Riverpod(keepAlive: true)
List<dynamic> getEventLoader(
  GetEventLoaderRef ref,
  DateTime day,
  List<Map<String, dynamic>> data,
) {
  final foodList = <DateTime, List<dynamic>>{};
  for (var i = 0; i < data.length; i++) {
    final posts = Posts(
      id: int.parse(data[i]['id'].toString()),
      userId: data[i]['user_id'],
      foodImage: data[i]['food_image'],
      foodName: data[i]['food_name'],
      restaurant: data[i]['restaurant'],
      comment: data[i]['comment'],
      createdAt: DateTime.parse(data[i]['created_at']),
      lat: double.parse(data[i]['lat'].toString()),
      lng: double.parse(data[i]['lng'].toString()),
      heart: int.parse(data[i]['heart'].toString()),
      restaurantTag: data[i]['restaurant_tag'],
      foodTag: data[i]['food_tag'],
    );
    final eventDate = posts.createdAt;
    if (foodList[eventDate] == null) {
      foodList[eventDate] = [];
    }
    foodList[eventDate]?.add(posts);
  }
  return getEventForDay(day, foodList);
}

List getEventForDay(DateTime day, Map<DateTime, List<dynamic>> foodList) {
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  final events = LinkedHashMap<DateTime, List<dynamic>>(
    equals: isSameDay,
    hashCode: getHashCode,
  )..addAll(foodList);

  return events[day] ?? [];
}
