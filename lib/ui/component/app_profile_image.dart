import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/main.dart';

class AppProfileImage extends StatelessWidget {
  const AppProfileImage({
    required this.imagePath,
    required this.radius,
    super.key,
  });

  final String imagePath;
  final double radius;

  @override
  Widget build(BuildContext context) {
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
