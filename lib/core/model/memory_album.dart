import 'dart:convert';

/// 食の思い出アルバム（メタデータのみ。画像は投稿から参照）
class MemoryAlbum {
  const MemoryAlbum({
    required this.id,
    required this.title,
    required this.description,
    required this.postIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MemoryAlbum.fromJson(Map<String, dynamic> json) {
    final rawIds = json['postIds'];
    return MemoryAlbum(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      postIds: rawIds is List
          ? rawIds.map((e) => (e as num).toInt()).toList()
          : const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String id;
  final String title;
  final String description;

  /// ユーザーが選択した順序（カバー = postIds.first）
  final List<int> postIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  int? get coverPostId => postIds.isEmpty ? null : postIds.first;

  int get postCount => postIds.length;

  static const _version = 1;

  Map<String, dynamic> toJson() => {
        'v': _version,
        'id': id,
        'title': title,
        'description': description,
        'postIds': postIds,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  MemoryAlbum copyWith({
    String? title,
    String? description,
    List<int>? postIds,
    DateTime? updatedAt,
  }) {
    return MemoryAlbum(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      postIds: postIds ?? this.postIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MemoryAlbumStore {
  const MemoryAlbumStore({required this.albums});

  factory MemoryAlbumStore.fromJsonString(String raw) {
    if (raw.isEmpty) {
      return const MemoryAlbumStore(albums: []);
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final list = decoded['albums'] as List<dynamic>? ?? [];
      return MemoryAlbumStore(
        albums: list
            .map((e) => MemoryAlbum.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on Object {
      return const MemoryAlbumStore(albums: []);
    }
  }

  final List<MemoryAlbum> albums;

  static const _version = 1;

  Map<String, dynamic> toJson() => {
        'v': _version,
        'albums': albums.map((a) => a.toJson()).toList(),
      };

  String toJsonString() => jsonEncode(toJson());
}

enum MemoryAlbumError {
  emptyTitle,
  emptyPostIds,
  albumNotFound,
}
