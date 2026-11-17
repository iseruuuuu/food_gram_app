import 'dart:convert';

/// 投稿画面の下書き（写真パス・バイナリは含まない）
class PostDraft {
  const PostDraft({
    required this.id,
    required this.savedAt,
    required this.foodName,
    required this.comment,
    required this.priceInput,
    required this.restaurant,
    required this.lat,
    required this.lng,
    required this.foodTags,
    required this.star,
    required this.isAnonymous,
    required this.priceCurrency,
  });

  final String id;
  final DateTime savedAt;
  final String foodName;
  final String comment;
  final String priceInput;
  final String restaurant;
  final double lat;
  final double lng;
  final List<String> foodTags;
  final double star;
  final bool isAnonymous;
  final String priceCurrency;

  static const _version = 1;

  bool get hasRestorableContent {
    final hasText =
        foodName.isNotEmpty ||
        comment.isNotEmpty ||
        priceInput.isNotEmpty ||
        foodTags.isNotEmpty;
    final hasPlace = restaurant.isNotEmpty && restaurant != '場所を追加';
    final hasGeo = lat != 0 || lng != 0;
    return hasText || hasPlace || hasGeo || star > 0 || isAnonymous;
  }

  /// 空白や通貨の大文字小文字を除いて、投稿内容が同じか。
  bool hasSameContentAs(PostDraft other) {
    return _normalizedText(foodName) == _normalizedText(other.foodName) &&
        _normalizedText(comment) == _normalizedText(other.comment) &&
        _normalizedText(priceInput) == _normalizedText(other.priceInput) &&
        _normalizedText(restaurant) == _normalizedText(other.restaurant) &&
        _sameCoordinate(lat, other.lat) &&
        _sameCoordinate(lng, other.lng) &&
        _tagKey(foodTags) == _tagKey(other.foodTags) &&
        (star - other.star).abs() < 0.001 &&
        isAnonymous == other.isAnonymous &&
        _normalizedText(priceCurrency).toUpperCase() ==
            _normalizedText(other.priceCurrency).toUpperCase();
  }

  Map<String, dynamic> toJson() => {
    'v': _version,
    'id': id,
    'savedAt': savedAt.millisecondsSinceEpoch,
    'foodName': foodName,
    'comment': comment,
    'priceInput': priceInput,
    'restaurant': restaurant,
    'lat': lat,
    'lng': lng,
    'foodTags': foodTags,
    'star': star,
    'isAnonymous': isAnonymous,
    'priceCurrency': priceCurrency,
  };

  static PostDraft? fromJson(Map<String, dynamic> decoded) {
    try {
      if (decoded['v'] is! int) {
        return null;
      }
      final tags = decoded['foodTags'];
      final rawId = decoded['id'];
      final id = rawId == null ? '' : rawId.toString();
      final savedAtRaw = decoded['savedAt'];
      return PostDraft(
        id: id.isEmpty ? 'legacy' : id,
        savedAt: savedAtRaw is num
            ? DateTime.fromMillisecondsSinceEpoch(savedAtRaw.toInt())
            : DateTime.now(),
        foodName: decoded['foodName'] as String? ?? '',
        comment: decoded['comment'] as String? ?? '',
        priceInput: decoded['priceInput'] as String? ?? '',
        restaurant: decoded['restaurant'] as String? ?? '場所を追加',
        lat: (decoded['lat'] as num?)?.toDouble() ?? 0,
        lng: (decoded['lng'] as num?)?.toDouble() ?? 0,
        foodTags: tags is List
            ? tags.map((e) => e.toString()).toList()
            : const <String>[],
        star: (decoded['star'] as num?)?.toDouble() ?? 0,
        isAnonymous: decoded['isAnonymous'] as bool? ?? false,
        priceCurrency: decoded['priceCurrency'] as String? ?? '',
      );
    } on Object {
      return null;
    }
  }

  static String _normalizedText(String value) => value.trim();

  static bool _sameCoordinate(double a, double b) => (a - b).abs() < 0.000001;

  static String _tagKey(List<String> tags) {
    final normalized =
        tags.map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList()
          ..sort();
    return normalized.join('\u0001');
  }
}

enum PostDraftSaveResult {
  empty,
  saved,
  unchanged,
  created,
  trimmed,
}

/// 端末内の下書き一覧。先頭が新しい。
class PostDraftList {
  const PostDraftList(this.items);

  factory PostDraftList.decode(String raw) {
    if (raw.isEmpty) {
      return const PostDraftList([]);
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const PostDraftList([]);
      }
      final map = Map<String, dynamic>.from(decoded);
      final storedItems = map['items'];
      if (storedItems is List) {
        return PostDraftList(_parseItems(storedItems));
      }
      final single = PostDraft.fromJson(map);
      if (single == null || !single.hasRestorableContent) {
        return const PostDraftList([]);
      }
      return PostDraftList([single]);
    } on Object {
      return const PostDraftList([]);
    }
  }

  static const maxCount = 20;
  static const _storeVersion = 2;

  final List<PostDraft> items;

  PostDraftList upsert(PostDraft draft) {
    final next = <PostDraft>[
      draft,
      for (final item in items)
        if (item.id != draft.id) item,
    ];
    if (next.length <= maxCount) {
      return PostDraftList(next);
    }
    return PostDraftList(next.sublist(0, maxCount));
  }

  PostDraftList removeByIds(Set<String> ids) {
    if (ids.isEmpty) {
      return this;
    }
    return PostDraftList([
      for (final item in items)
        if (!ids.contains(item.id)) item,
    ]);
  }

  String encode() => jsonEncode({
    'v': _storeVersion,
    'items': items.map((item) => item.toJson()).toList(),
  });

  static bool isLegacyPayload(String raw) {
    if (raw.isEmpty) {
      return false;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return false;
      }
      return decoded['items'] is! List;
    } on Object {
      return false;
    }
  }

  static List<PostDraft> _parseItems(List<dynamic> storedItems) {
    final drafts = <PostDraft>[];
    final seen = <String>{};
    for (final item in storedItems) {
      if (item is! Map) {
        continue;
      }
      final draft = PostDraft.fromJson(Map<String, dynamic>.from(item));
      if (draft == null || !draft.hasRestorableContent) {
        continue;
      }
      if (seen.add(draft.id)) {
        drafts.add(draft);
      }
    }
    return drafts;
  }
}
