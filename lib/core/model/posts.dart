import 'package:food_gram_app/core/utils/format/post_price_formatter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'posts.freezed.dart';
part 'posts.g.dart';

@freezed
abstract class Posts with _$Posts {
  const factory Posts({
    required int id,
    required String foodImage,
    required String foodName,
    required String restaurant,
    required String comment,
    required DateTime createdAt,
    required double lat,
    required double lng,
    required String userId,
    required int heart,
    @JsonKey(defaultValue: 0.0) required double star,
    required String foodTag,
    required bool isAnonymous,
    @JsonKey(fromJson: nullableDoubleFromJson) double? priceAmount,
    String? priceCurrency,
  }) = _Posts;

  factory Posts.fromJson(Map<String, dynamic> json) => _$PostsFromJson(json);
}

/// Supabase Storage のオブジェクトキーとしてそのまま使える文字列か
/// （ローカル一時パスなどは false）。
bool isSupabaseFoodStorageObjectPath(String path) {
  if (path.trim().isEmpty) {
    return false;
  }
  final p = path.toLowerCase();
  if (p.contains('private/var')) {
    return false;
  }
  if (p.contains('image_cropper')) {
    return false;
  }
  if (p.contains('containers/data')) {
    return false;
  }
  if (p.contains('data/application')) {
    return false;
  }
  return true;
}

bool _looksLikeLegacyLocalFoodPath(String normalized) {
  final p = normalized.toLowerCase();
  return p.contains('private/var') ||
      p.contains('image_cropper') ||
      p.contains('containers/data') ||
      (p.contains('data/application') && p.contains('tmp'));
}

String? _legacyImageFileName(String normalized) {
  final parts = normalized.split('/').where((s) => s.isNotEmpty).toList();
  if (parts.isEmpty) {
    return null;
  }
  final last = parts.last;
  if (last.isEmpty) {
    return null;
  }
  final lower = last.toLowerCase();
  if (lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp')) {
    return last;
  }
  return null;
}

/// 表示用に Storage オブジェクトキーへ落とし込む。
/// [normalized] は先頭 `/` を含まない想定（[normalizeFoodImageObjectKeyForDisplay] 経由）。
/// 通常はそのまま返し、レガシー（ローカルパス混入）のみ
/// `投稿の userId` + 末尾ファイル名 で再構成する（当時アップロードされたキーと一致しやすい）。
String resolveFoodImagePathForDisplay(String normalized, String postUserId) {
  if (normalized.isEmpty) {
    return '';
  }
  if (isSupabaseFoodStorageObjectPath(normalized)) {
    return normalized;
  }
  if (!_looksLikeLegacyLocalFoodPath(normalized)) {
    return '';
  }
  final fileName = _legacyImageFileName(normalized);
  if (fileName == null) {
    return '';
  }
  final uid = postUserId.trim();
  if (uid.isEmpty) {
    return '';
  }
  return '$uid/$fileName';
}

/// 生の `food_image` セグメント1つを、`getPublicUrl` 用の Storage キーへ正規化する。
/// 先頭 `/` を剥がしてから [resolveFoodImagePathForDisplay] する（カード・一覧で共有）。
String normalizeFoodImageObjectKeyForDisplay(
  String rawSegment,
  String postUserId,
) {
  var p = rawSegment.trim();
  while (p.startsWith('/')) {
    p = p.substring(1);
  }
  if (p.isEmpty) {
    return '';
  }
  return resolveFoodImagePathForDisplay(p, postUserId);
}

extension PostsExtension on Posts {
  /// カンマ区切りのfoodImageから画像パスのリストを取得
  List<String> get foodImageList {
    if (foodImage.isEmpty) {
      return [];
    }
    return foodImage
        .split(',')
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .map((path) => normalizeFoodImageObjectKeyForDisplay(path, userId))
        .where((path) => path.isNotEmpty)
        .toList();
  }

  /// 最初の画像の Storage オブジェクトキー（`getPublicUrl` 用・先頭 `/` なし）
  String get firstFoodImage {
    if (foodImage.isEmpty) {
      return '';
    }
    return normalizeFoodImageObjectKeyForDisplay(
      foodImage.split(',').first,
      userId,
    );
  }

  /// 参考価格の表示文字列。未設定なら空。
  String get formattedPriceDisplay {
    final amount = priceAmount;
    final code = priceCurrency?.trim();
    if (amount == null || code == null || code.isEmpty) {
      return '';
    }
    return formatPostPriceDisplay(amount: amount, currencyCode: code);
  }
}
