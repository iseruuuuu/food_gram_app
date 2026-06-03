import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/share/templates/post_share_cafe_template.dart';
import 'package:food_gram_app/ui/component/share/templates/post_share_classic_template.dart';
import 'package:food_gram_app/ui/component/share/templates/post_share_map_template.dart';
import 'package:food_gram_app/ui/component/share/templates/post_share_minimal_template.dart';
import 'package:food_gram_app/ui/component/share/templates/post_share_special_template.dart';
import 'package:food_gram_app/ui/component/share/templates/post_share_story_template.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum PostShareTemplateCategory {
  all,
  simple,
  story,
  cafe,
  minimal,
  map,
}

enum PostShareTemplateId {
  classic,
  story,
  cafe,
  special,
  map,
  minimal,
}

class PostShareTemplateDefinition {
  const PostShareTemplateDefinition({
    required this.id,
    required this.category,
    required this.size,
    required this.name,
    required this.description,
    required this.builder,
  });

  final PostShareTemplateId id;
  final PostShareTemplateCategory category;
  final Size size;
  final String Function(Translations t) name;
  final String Function(Translations t) description;
  final Widget Function(Posts posts, WidgetRef ref, Translations t) builder;
}

/// 投稿シェア用テンプレート一覧。新しいテンプレートはここに追加する。
final List<PostShareTemplateDefinition> postShareTemplates = [
  PostShareTemplateDefinition(
    id: PostShareTemplateId.story,
    category: PostShareTemplateCategory.story,
    size: PostShareStoryTemplate.size,
    name: (t) => t.share.templateStoryName,
    description: (t) => t.share.templateStoryDescription,
    builder: (posts, ref, t) =>
        PostShareStoryTemplate(posts: posts, ref: ref),
  ),
  PostShareTemplateDefinition(
    id: PostShareTemplateId.classic,
    category: PostShareTemplateCategory.simple,
    size: PostShareClassicTemplate.size,
    name: (t) => t.share.templateClassicName,
    description: (t) => t.share.templateClassicDescription,
    builder: (posts, ref, t) =>
        PostShareClassicTemplate(posts: posts, ref: ref),
  ),
  PostShareTemplateDefinition(
    id: PostShareTemplateId.cafe,
    category: PostShareTemplateCategory.cafe,
    size: PostShareCafeTemplate.size,
    name: (t) => t.share.templateCafeName,
    description: (t) => t.share.templateCafeDescription,
    builder: (posts, ref, t) =>
        PostShareCafeTemplate(posts: posts, ref: ref, t: t),
  ),
  PostShareTemplateDefinition(
    id: PostShareTemplateId.special,
    category: PostShareTemplateCategory.story,
    size: PostShareSpecialTemplate.size,
    name: (t) => t.share.templateSpecialName,
    description: (t) => t.share.templateSpecialDescription,
    builder: (posts, ref, t) =>
        PostShareSpecialTemplate(posts: posts, ref: ref, t: t),
  ),
  PostShareTemplateDefinition(
    id: PostShareTemplateId.map,
    category: PostShareTemplateCategory.map,
    size: PostShareMapTemplate.size,
    name: (t) => t.share.templateMapName,
    description: (t) => t.share.templateMapDescription,
    builder: (posts, ref, t) =>
        PostShareMapTemplate(posts: posts, ref: ref, t: t),
  ),
  PostShareTemplateDefinition(
    id: PostShareTemplateId.minimal,
    category: PostShareTemplateCategory.minimal,
    size: PostShareMinimalTemplate.size,
    name: (t) => t.share.templateMinimalName,
    description: (t) => t.share.templateMinimalDescription,
    builder: (posts, ref, t) =>
        PostShareMinimalTemplate(posts: posts, ref: ref),
  ),
];

PostShareTemplateDefinition postShareTemplateById(PostShareTemplateId id) {
  return postShareTemplates.firstWhere((template) => template.id == id);
}

List<PostShareTemplateDefinition> filteredPostShareTemplates(
  PostShareTemplateCategory category,
) {
  if (category == PostShareTemplateCategory.all) {
    return postShareTemplates;
  }
  return postShareTemplates
      .where((template) => template.category == category)
      .toList();
}

String postShareCategoryLabel(
  PostShareTemplateCategory category,
  Translations t,
) {
  return switch (category) {
    PostShareTemplateCategory.all => t.share.categoryAll,
    PostShareTemplateCategory.simple => t.share.categorySimple,
    PostShareTemplateCategory.story => t.share.categoryStory,
    PostShareTemplateCategory.cafe => t.share.categoryCafe,
    PostShareTemplateCategory.minimal => t.share.categoryMinimal,
    PostShareTemplateCategory.map => t.share.categoryMap,
  };
}
