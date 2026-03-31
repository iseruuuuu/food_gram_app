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

bool _looksLikeLocalFilePath(String normalized) {
  final p = normalized.toLowerCase();
  return p.startsWith('file://') ||
      p.startsWith('content://') ||
      p.startsWith('/private/var/') ||
      p.startsWith('/var/mobile/') ||
      p.startsWith('/data/user/0/') ||
      p.contains('image_cropper') ||
      p.contains('containers/data') ||
      p.contains('data/application');
}

/// Supabase Storage のオブジェクトキーとしてそのまま使える文字列か
/// （ローカル一時パスなどは false）。
bool isSupabaseFoodStorageObjectPath(String path) {
  final normalized = path.trim();
  if (normalized.isEmpty) {
    return false;
  }
  return !_looksLikeLocalFilePath(normalized);
}

bool _looksLikeLegacyLocalFoodPath(String normalized) {
  return _looksLikeLocalFilePath(normalized);
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
      lower.endsWith('.webp') ||
      lower.endsWith('.heic') ||
      lower.endsWith('.gif')) {
    return last;
  }
  return null;
}

/// DB にフルの公開 URL が入っている旧データ向け。
/// `getPublicUrl` はオブジェクトキー（バケット名なし）を想定するため、
/// ここで `uid/file.jpg` 形式へ落とす。
String? _objectKeyFromSupabaseFoodPublicUrl(String raw) {
  final t = raw.trim();
  if (!t.startsWith('http://') && !t.startsWith('https://')) {
    return null;
  }
  final uri = Uri.tryParse(t);
  if (uri == null) {
    return null;
  }
  final path = uri.path;
  const marker = '/object/public/food/';
  final i = path.indexOf(marker);
  if (i == -1) {
    return null;
  }
  final encoded = path.substring(i + marker.length);
  if (encoded.isEmpty) {
    return null;
  }
  return Uri.decodeComponent(encoded);
}

/// `food_image` にバケット名まで含めて保存されていた場合の二重プレフィックス防止。
String _stripFoodBucketPrefixIfPresent(String normalized) {
  const prefix = 'food/';
  if (normalized.startsWith(prefix)) {
    return normalized.substring(prefix.length);
  }
  return normalized;
}

/// 旧バグ: `/uid//private/var/.../image_cropper_xxx.jpg` のように
/// UUID とローカル一時パスが連結されていた場合、先頭の UUID をフォルダとして使う。
String? _legacyUidFromUuidThenLocalPath(String normalized) {
  final idx = normalized.indexOf('//');
  if (idx <= 0) {
    return null;
  }
  final prefix = normalized.substring(0, idx).trim();
  final rest = normalized.substring(idx + 2);
  if (rest.isEmpty || !_looksLikeLocalFilePath(rest)) {
    return null;
  }
  final uuidRe = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  if (!uuidRe.hasMatch(prefix)) {
    return null;
  }
  return prefix;
}

/// 表示用に Storage オブジェクトキーへ落とし込む。
/// [normalized] は先頭 `/` を含まない想定（[normalizeFoodImageObjectKeyForDisplay] 経由）。
/// 通常はそのまま返し、レガシー（ローカルパス混入）のみ
/// `投稿の userId` + 末尾ファイル名 で再構成する（当時アップロードされたキーと一致しやすい）。
String resolveFoodImagePathForDisplay(String normalized, String postUserId) {
  if (normalized.isEmpty) {
    return '';
  }
  final fromPublicUrl = _objectKeyFromSupabaseFoodPublicUrl(normalized);
  if (fromPublicUrl != null && fromPublicUrl.isNotEmpty) {
    return _stripFoodBucketPrefixIfPresent(fromPublicUrl);
  }
  var key = _stripFoodBucketPrefixIfPresent(normalized);

  // 旧データの中には、Storage にもローカル一時パスを含んだまま
  // （例: `uid//private/var/mobile/.../tmp/image_cropper_....jpg`）
  // 保存されているものがあります。
  // この場合は「uid/filename へ縮退」しないで、Storage 側のキーと一致させる必要があります。
  final legacyUuidThenDoubleSlashLocalPath = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}//'
    r'(private/var/mobile/Containers/Data/Application|private/var/|var/mobile/|containers/data|data/application|data/user/0/)',
  );
  if (legacyUuidThenDoubleSlashLocalPath.hasMatch(key)) {
    return key;
  }
  if (isSupabaseFoodStorageObjectPath(key)) {
    return key;
  }
  if (!_looksLikeLegacyLocalFoodPath(normalized)) {
    return '';
  }
  final fileName = _legacyImageFileName(normalized);
  if (fileName == null) {
    return '';
  }
  final fromPath = _legacyUidFromUuidThenLocalPath(normalized);
  final uid = (fromPath ?? postUserId).trim();
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
    final images = foodImageList;
    return images.isNotEmpty ? images.first : '';
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
