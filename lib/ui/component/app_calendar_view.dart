import 'package:flutter/material.dart';
import 'package:food_gram_app/ui/component/app_empty.dart';
import 'package:table_calendar/table_calendar.dart';

class AppCalendarView extends StatelessWidget {
  const AppCalendarView({
    required this.data,
    required this.refresh,
    super.key,
  });

  final List<Map<String, dynamic>> data;
  final Function() refresh;

  @override
  Widget build(BuildContext context) {
    //TODO カレンダーに切り替える

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
            //TODO 多言語化をする

            //TODO 投稿した日にピンを落とす
          ),
        ),
        // child: ListView.builder(
        //   itemCount: data.length,
        //   itemBuilder: (context, index) {
        //     return ListTile(
        //       title: Row(
        //         children: [
        //           Text(
        //             'in ${data[index]['restaurant']}',
        //             style: TextStyle(
        //               fontWeight: FontWeight.bold,
        //               fontSize: 15,
        //               color: Colors.black,
        //             ),
        //           ),
        //         ],
        //       ),
        //       subtitle: Text(
        //         data[index]['food_name'],
        //         style: TextStyle(
        //           color: Colors.grey,
        //           fontSize: 13,
        //           fontWeight: FontWeight.normal,
        //         ),
        //       ),
        //     );
        //   },
        // ),
      );
    } else {
      return AppEmpty();
    }
  }
}
