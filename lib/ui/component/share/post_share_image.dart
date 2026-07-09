import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostShareImage extends StatelessWidget {
  const PostShareImage({
    required this.imageUrl,
    super.key,
  });

  final String imageUrl;

  static const Color _fallbackColor = Color(0xFFE8E2D8);

  static Widget _fallback() {
    return const ColoredBox(
      color: _fallbackColor,
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: Color(0xFF9E9588),
          size: 48,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      filterQuality: FilterQuality.high,
      placeholder: (_, __) => _fallback(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }
}
