import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              t.errorTitle,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${t.errorDescription1}'
              '\n'
              '${t.errorDescription2}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Assets.image.error.image(
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 50),
            AppElevatedButton(
              onPressed: onTap,
              title: t.errorRefreshButton,
            ),
          ],
        ),
      ),
    );
  }
}
