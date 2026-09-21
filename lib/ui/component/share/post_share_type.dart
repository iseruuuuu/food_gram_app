import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/ui/component/share/post/post_share_cafe.dart';
import 'package:food_gram_app/ui/component/share/post/post_share_classic.dart';
import 'package:food_gram_app/ui/component/share/post/post_share_special.dart';
import 'package:food_gram_app/ui/component/share/post/post_share_story.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum PostShare {
  story,
  classic,
  cafe,
  special,
  ;

  Size get size => switch (this) {
        story => PostShareStory.size,
        classic => PostShareClassic.size,
        cafe => PostShareCafe.size,
        special => PostShareSpecialTemplate.size,
      };

  Widget toWidget({
    required Posts posts,
    required WidgetRef ref,
  }) {
    return switch (this) {
      story => PostShareStory(posts: posts, ref: ref),
      classic => PostShareClassic(posts: posts, ref: ref),
      cafe => PostShareCafe(posts: posts, ref: ref),
      special => PostShareSpecialTemplate(posts: posts, ref: ref),
    };
  }
}
