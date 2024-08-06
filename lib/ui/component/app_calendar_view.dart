import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/utils/get_event_loader.dart';
import 'package:food_gram_app/ui/component/app_empty.dart';
import 'package:table_calendar/table_calendar.dart';

class AppCalendarView extends ConsumerWidget {
  const AppCalendarView({
    required this.data,
    required this.refresh,
    super.key,
  });

  final List<Map<String, dynamic>> data;
  final Function() refresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isNotEmpty) {
      return RefreshIndicator(
        color: Colors.black,
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1));
          refresh();
        },
        child: SingleChildScrollView(
          child: TableCalendar(
            firstDay: DateTime.utc(2010),
            lastDay: DateTime.utc(2030),
            focusedDay: DateTime.now(),
            daysOfWeekVisible: false,
            eventLoader: (value) {
              return ref.watch(getEventLoaderProvider(value, data));
            },
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: Colors.black),
            ),
          ),
        ),
      );
    } else {
      return AppEmpty();
    }
  }
}
