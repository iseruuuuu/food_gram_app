import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';

class HeartHelper {
  Future<void> handleHeart(
    WidgetRef ref,
    Users users,
    Posts posts,
    ValueNotifier<int> initialHeart,
    ValueNotifier<bool> isHeart,
    ValueNotifier<bool> isAppearHeart,
    ValueNotifier<List<String>> heartList,
  ) async {
    final currentUser = ref.watch(currentUserProvider);
    final supabase = ref.watch(supabaseProvider);
    final preference = Preference();
    if (users.userId == currentUser) {
      return;
    }
    final postId = posts.id.toString();
    final currentHeart = initialHeart.value;
    if (isHeart.value) {
      await supabase.from('posts').update({
        'heart': currentHeart - 1,
      }).match({'id': posts.id});
      initialHeart.value--;
      isHeart.value = false;
      isAppearHeart.value = false;
      heartList.value = List.from(heartList.value)..remove(postId);
    } else {
      await supabase.from('posts').update({
        'heart': currentHeart + 1,
      }).match({'id': posts.id});
      initialHeart.value++;
      isHeart.value = true;
      isAppearHeart.value = true;
      heartList.value = List.from(heartList.value)..add(postId);
    }
    await preference.setStringList(
      PreferenceKey.heartList,
      heartList.value,
    );
  }
}
