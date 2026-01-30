import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:go_router/go_router.dart';
import 'package:map_launcher/map_launcher.dart';

class AppMapSelectModalSheet extends StatelessWidget {
  const AppMapSelectModalSheet({
    required this.onMapSelected,
    super.key,
  });

  final void Function(MapType mapType) onMapSelected;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2.1,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 20,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.selectMapApp,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3.5,
                      children: [
                        _MapOptionItem(
                          mapType: MapType.google,
                          title: t.mapAppGoogle,
                          onTap: () {
                            context.pop();
                            onMapSelected(MapType.google);
                          },
                        ),
                        _MapOptionItem(
                          mapType: MapType.apple,
                          title: t.mapAppApple,
                          onTap: () {
                            context.pop();
                            onMapSelected(MapType.apple);
                          },
                        ),
                        _MapOptionItem(
                          mapType: MapType.baidu,
                          title: t.mapAppBaidu,
                          onTap: () {
                            context.pop();
                            onMapSelected(MapType.baidu);
                          },
                        ),
                        _MapOptionItem(
                          mapType: MapType.mapswithme,
                          title: t.mapAppMapsMe,
                          onTap: () {
                            context.pop();
                            onMapSelected(MapType.mapswithme);
                          },
                        ),
                        _MapOptionItem(
                          mapType: MapType.kakao,
                          title: t.mapAppKakao,
                          onTap: () {
                            context.pop();
                            onMapSelected(MapType.kakao);
                          },
                        ),
                        _MapOptionItem(
                          mapType: MapType.naver,
                          title: t.mapAppNaver,
                          onTap: () {
                            context.pop();
                            onMapSelected(MapType.naver);
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Divider(),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        t.close,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapOptionItem extends StatelessWidget {
  const _MapOptionItem({
    required this.mapType,
    required this.title,
    required this.onTap,
  });

  final MapType mapType;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
