import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/ui/component/share/templates/post_share_classic_template.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 後方互換のため残している。新規実装は [PostShareClassicTemplate] を利用する。
class ShareWidget extends StatelessWidget {
  const ShareWidget({
    required this.posts,
    required this.ref,
    super.key,
  });

  final Posts posts;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return PostShareClassicTemplate(posts: posts, ref: ref);
  }
}
