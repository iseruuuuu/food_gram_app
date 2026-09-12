import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/local/want_to_go_actions.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/restaurant/restaurant_display_name.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ピンタップ時の店舗カード。代表写真と店情報、他投稿のサムネを出す。
class MapSelectedPostCard extends HookConsumerWidget {
  const MapSelectedPostCard({
    required this.posts,
    required this.restaurantName,
    required this.lat,
    required this.lng,
    required this.onOpenPost,
    this.address = '',
    this.onClose,
    super.key,
  });

  final List<Posts> posts;
  final String restaurantName;
  final double lat;
  final double lng;
  final String address;
  final VoidCallback? onClose;
  final ValueChanged<Posts> onOpenPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final supabase = ref.watch(supabaseProvider);
    final selectedIndex = useState(0);
    final postIds = posts.map((p) => p.id).join(',');
    useEffect(
      () {
        selectedIndex.value = 0;
        return null;
      },
      [postIds],
    );
    if (posts.isEmpty) {
      return const SizedBox.shrink();
    }
    final index = selectedIndex.value.clamp(0, posts.length - 1);
    final post = posts[index];
    final imageUrl = _imageUrl(supabase, post);
    final foodName = post.foodName.trim();
    final comment = post.comment.trim();
    final price = post.formattedPriceDisplay;
    final star = post.star > 0 ? post.star : null;
    final restaurant = Restaurant(
      name: restaurantName,
      address: address,
      lat: lat,
      lng: lng,
    );
    final isInList = isWantToGoListed(ref, restaurant);
    const wantToGoAccent = Color(0xFFFF8A00);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () => onOpenPost(post),
                child: _FoodImage(imageUrl: imageUrl, isDark: isDark),
              ),
              if (onClose != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onClose,
                        child: Center(
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  localizedRestaurantName(restaurantName, t),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                    height: 1.2,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => toggleWantToGoWithFeedback(
                  context: context,
                  ref: ref,
                  restaurant: restaurant,
                ),
                visualDensity: VisualDensity.standard,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                icon: Icon(
                  isInList ? Icons.bookmark : Icons.bookmark_border,
                  color: isInList ? wantToGoAccent : onSurface,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
        if (foodName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
            child: Text(
              foodName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                color: muted,
                height: 1.3,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              if (star != null) ...[
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFC107),
                  size: 18,
                ),
                const SizedBox(width: 2),
                Text(
                  star.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
              ],
              if (price.isNotEmpty) ...[
                if (star != null)
                  Text(
                    '  ·  ',
                    style: TextStyle(fontSize: 13, color: muted),
                  ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
              ],
              const Spacer(),
              Icon(
                Icons.favorite_border,
                size: 18,
                color: muted,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.heart}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
        if (address.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: muted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    address.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: muted,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (comment.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: onSurface,
                height: 1.45,
              ),
            ),
          ),
        if (posts.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                primary: false,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final item = posts[i];
                  final thumbUrl = _imageUrl(supabase, item);
                  final selected = i == index;
                  return GestureDetector(
                    onTap: () => selectedIndex.value = i,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primaryBlue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _FoodImage(
                          imageUrl: thumbUrl,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }
}

String? _imageUrl(SupabaseClient supabase, Posts post) {
  final path = post.firstFoodImage;
  if (path.isEmpty) {
    return null;
  }
  return supabase.storage.from('food').getPublicUrl(path);
}

class _FoodImage extends StatelessWidget {
  const _FoodImage({
    required this.imageUrl,
    required this.isDark,
  });

  final String? imageUrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Image.asset(
        isDark ? Assets.image.emptyDark.path : Assets.image.empty.path,
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => Image.asset(
        isDark ? Assets.image.emptyDark.path : Assets.image.empty.path,
        fit: BoxFit.cover,
      ),
    );
  }
}
