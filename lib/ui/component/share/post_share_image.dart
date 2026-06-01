import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostShareImage extends StatelessWidget {
  const PostShareImage({
    required this.imageUrl,
    super.key,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
