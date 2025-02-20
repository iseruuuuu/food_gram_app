import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';

class AppProfileImage extends ConsumerWidget {
  const AppProfileImage({
    required this.imagePath,
    required this.radius,
    super.key,
  });

  final String imagePath;
  final double radius;

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

    if (assetImages.contains(imagePath)) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        backgroundImage: AssetImage(imagePath),
      );
    } else {
      final foodImageUrl =
          supabase.storage.from('user').getPublicUrl(imagePath);
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        backgroundImage: CachedNetworkImageProvider(foodImageUrl),
      );
    }
  }
}
