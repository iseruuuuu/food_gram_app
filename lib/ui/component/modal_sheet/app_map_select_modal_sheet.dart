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
    final scheme = Theme.of(context).colorScheme;
    final handleColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[600]
        : Colors.grey[300];
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2.1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.only(
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
                  color: handleColor,
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
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.selectMapApp,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
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
                          title: t.mapApp.google,
                          onTap: () {
                            context.pop();
                            onMapSelected(MapType.google);
                          },
                        ),
                        _MapOptionItem(
                          mapType: MapType.apple,
                          title: t.mapApp.apple,
                          onTap: () {
                            context.pop();
                            onMapSelected(MapType.apple);
                          },
                        ),
                        _MapOptionItem(
                          mapType: MapType.baidu,
                          title: t.mapApp.baidu,
                          onTap: () {
                            context.pop();
                            onMapSelected(MapType.baidu);
                          },
                        ),
                        _MapOptionItem(
                          mapType: MapType.mapswithme,
                          title: t.mapApp.mapsMe,
                          onTap: () {
                            context.pop();
                            onMapSelected(MapType.mapswithme);
                          },
                        ),
                        _MapOptionItem(
                          mapType: MapType.kakao,
                          title: t.mapApp.kakao,
                          onTap: () {
                            context.pop();
                            onMapSelected(MapType.kakao);
                          },
                        ),
                        _MapOptionItem(
                          mapType: MapType.naver,
                          title: t.mapApp.naver,
                          onTap: () {
                            context.pop();
                            onMapSelected(MapType.naver);
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Divider(color: scheme.outlineVariant),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        t.close,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: scheme.error,
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
    final scheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? scheme.surfaceContainerHighest
        : Colors.grey[100]!;
    return Card(
      elevation: 0,
      color: cardColor,
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
