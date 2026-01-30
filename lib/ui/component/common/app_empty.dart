import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:gap/gap.dart';

class AppEmpty extends StatelessWidget {
  const AppEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Translations.of(context).emptyPosts,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Assets.image.empty.image(width: 110, height: 110),
        ],
      ),
    );
  }
}

class AppSearchResultEmpty extends StatelessWidget {
  const AppSearchResultEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Translations.of(context).search.emptyResult,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        Assets.gif.error.image(width: 180, height: 180),
      ],
    );
  }
}

class AppSearchEmpty extends StatelessWidget {
  const AppSearchEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Assets.gif.empty.image(width: 100, height: 100),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              Translations.of(context).searchEmptyTitle,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade100,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade700,
                      size: 28,
                    ),
                    const Gap(8),
                    Text(
                      Translations.of(context).search.emptyHintTitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        Translations.of(context).search.emptyHintLocation,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Row(
                  children: [
                    Icon(
                      Icons.map,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        Translations.of(context).search.emptyHintSearch,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(18),
        ],
      ),
    );
  }
}

class AppFavoritePostEmpty extends StatelessWidget {
  const AppFavoritePostEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Translations.of(context).favoritePostEmpty.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            Translations.of(context).favoritePostEmpty.subtitle,
            style: const TextStyle(fontSize: 14),
          ),
          Assets.gif.error.image(width: 180, height: 180),
        ],
      ),
    );
  }
}
