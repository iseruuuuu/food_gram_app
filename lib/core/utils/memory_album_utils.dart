import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:intl/intl.dart';

enum MemoryAlbumPostSort { newest, oldest }

String memoryAlbumLocaleTag() {
  final locale = LocaleSettings.currentLocale;
  final country = locale.countryCode;
  if (country != null && country.isNotEmpty) {
    return '${locale.languageCode}_$country';
  }
  return locale.languageCode;
}

String? postImageUrl(WidgetRef ref, Posts post) {
  final storageKey = post.firstFoodImage;
  if (storageKey.isEmpty) {
    return null;
  }
  return ref
      .read(supabaseProvider)
      .storage
      .from('food')
      .getPublicUrl(storageKey);
}

({DateTime? start, DateTime? end}) postDateRange(List<Posts> posts) {
  if (posts.isEmpty) {
    return (start: null, end: null);
  }
  var start = posts.first.createdAt;
  var end = posts.first.createdAt;
  for (final post in posts) {
    if (post.createdAt.isBefore(start)) {
      start = post.createdAt;
    }
    if (post.createdAt.isAfter(end)) {
      end = post.createdAt;
    }
  }
  return (start: start, end: end);
}

String formatAlbumDateRange(DateTime? start, DateTime? end) {
  if (start == null || end == null) {
    return '';
  }
  final fmt = DateFormat('yyyy.MM.dd', memoryAlbumLocaleTag());
  if (fmt.format(start) == fmt.format(end)) {
    return fmt.format(start);
  }
  return '${fmt.format(start)} - ${fmt.format(end)}';
}

String formatMemoryAlbumPostDate(DateTime date) {
  return DateFormat.yMMMd(memoryAlbumLocaleTag()).format(date);
}

List<Posts> sortAlbumPosts(List<Posts> posts, MemoryAlbumPostSort sort) {
  final sorted = [...posts];
  switch (sort) {
    case MemoryAlbumPostSort.newest:
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case MemoryAlbumPostSort.oldest:
      sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }
  return sorted;
}

List<Posts> postsWithImages(List<Posts> posts, {int max = 3}) {
  final out = <Posts>[];
  for (final post in posts) {
    if (post.firstFoodImage.isNotEmpty) {
      out.add(post);
    }
    if (out.length >= max) {
      break;
    }
  }
  return out;
}
