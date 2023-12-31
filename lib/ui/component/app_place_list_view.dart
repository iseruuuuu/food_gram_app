import 'package:flutter/material.dart';
import 'package:food_gram_app/ui/component/app_empty.dart';

class AppPlaceListView extends StatelessWidget {
  const AppPlaceListView({
    required this.data,
    required this.refresh,
    super.key,
  });

  final List<Map<String, dynamic>> data;
  final Function() refresh;

  @override
  Widget build(BuildContext context) {
    return data.isNotEmpty
        ? RefreshIndicator(
            color: Colors.black,
            onRefresh: () async {
              await Future.delayed(Duration(seconds: 1));
              refresh();
            },
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Row(
                    children: [
                      Text(
                        'in ${data[index]['restaurant']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    data[index]['food_name'],
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          )
        : AppEmpty();
  }
}
