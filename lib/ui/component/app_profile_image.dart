import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';

class AppProfileImage extends ConsumerWidget {
  const AppProfileImage({
    required this.imagePath,
    required this.radius,
    this.borderWidth = 0.0,
    this.borderColor = Colors.white,
    super.key,
  });

  final String imagePath;
  final double radius;
  final double borderWidth;
  final Color borderColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseProvider);
    const assetImages = <String>[
      'assets/icon/icon1.png',
      'assets/icon/icon2.png',
      'assets/icon/icon3.png',
      'assets/icon/icon4.png',
      'assets/icon/icon5.png',
      'assets/icon/icon6.png',
    ];

    Widget buildCircleAvatar() {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: ClipOval(
          child: assetImages.contains(imagePath)
              ? Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl:
                      supabase.storage.from('user').getPublicUrl(imagePath),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
        ),
      );
    }

    return buildCircleAvatar();
  }
}
