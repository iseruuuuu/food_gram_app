import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/home_widget/map_stats_home_widget_sync.dart';
import 'package:food_gram_app/core/model/food_tag_registry.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

/// 投稿した日付と料理タグ（絵文字またはカスタムタグ画像）を
/// iOS ホームウィジェット（PostCalendarWidget）へ同期する。
///
/// ローカルタイムゾーン基準の `yyyy-MM-dd` ごとに、その日の最新投稿の料理タグを
/// App Group（`group.com.FoodGram.ios`）の `UserDefaults` に保存し、
/// WidgetKit 側で当月のカレンダー上にスタンプを描画する。
class CalendarHomeWidgetSync {
  CalendarHomeWidgetSync._();

  static final _log = Logger();

  static const appGroupId = MapStatsHomeWidgetSync.appGroupId;
  static const iosWidgetKind = 'PostCalendarWidget';
  static const payloadKey = 'post_calendar_payload';

  static const _syncDebounceDuration = Duration(milliseconds: 500);
  static final _dateFormatter = DateFormat('yyyy-MM-dd');
  static const _defaultFoodEmoji = '🍽️';
  static const _customTagIconDimension = 72;

  static final Map<String, String> _customTagBase64Cache = {};

  /// カスタムタグ画像が読み込めない場合や旧ウィジェット向けのフォールバック絵文字
  static const Map<String, String> _customTagFallbackEmoji = {
    'tag:meibutsu': '🍱',
    'tag:souvenir': '🎁',
    'tag:udon': '🍜',
    'tag:soba': '🍜',
    'tag:yakisoba': '🍝',
    'tag:tonkatsu': '🍖',
    'tag:tantanmen': '🍜',
    'tag:takoyaki': '🐙',
    'tag:tsukune': '🍢',
    'tag:omurice': '🍳',
    'tag:tamagoyaki': '🥚',
    'tag:frenchtoast': '🍞',
    'tag:montblanc': '🧁',
    'tag:stew': '🍲',
    'tag:hamburg': '🥩',
    'tag:yakiniku': '🥩',
    'tag:tendon': '🍤',
    'tag:katsudon': '🍚',
    'tag:kaisendon': '🍣',
    'tag:mochi': '🍡',
    'tag:melonpan': '🥐',
    'tag:chahan': '🍚',
    'tag:okonomiyaki': '🥞',
    'tag:mapo': '🍲',
    'tag:gyutan': '🥩',
    'tag:xiaolongbao': '🥟',
    'tag:chikinnanban': '🍗',
    'tag:churro': '🥖',
    'tag:shu': '🧁',
  };

  static Timer? _debounceTimer;
  static List<Posts>? _pendingPosts;
  static Future<void>? _syncChain;

  /// 投稿一覧から投稿日（ローカル日付）とタグを抽出し、デバウンス付きでウィジェットへ同期する。
  static void scheduleSyncFromPosts(List<Posts> posts) {
    if (!Platform.isIOS) {
      return;
    }
    _pendingPosts = List<Posts>.from(posts);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_syncDebounceDuration, () {
      _debounceTimer = null;
      final latestPosts = _pendingPosts;
      _pendingPosts = null;
      if (latestPosts == null) {
        return;
      }
      _syncChain = (_syncChain ?? Future<void>.value()).then(
        (_) => syncFromPosts(latestPosts),
      );
      unawaited(_syncChain);
    });
  }

  /// 投稿一覧から投稿日と料理タグを抽出し、即座にウィジェットへ反映する。
  static Future<void> syncFromPosts(List<Posts> posts) async {
    if (!Platform.isIOS) {
      return;
    }
    try {
      // 新しい投稿を優先するため、createdAt 降順でソートして同じ日の最新タグを採用する
      final sortedPosts = List<Posts>.from(posts)
        ..sort((a, b) {
          final cmp = b.createdAt.compareTo(a.createdAt);
          if (cmp != 0) {
            return cmp;
          }
          return b.id.compareTo(a.id);
        });

      final postedTagByDate = <String, String>{};
      for (final post in sortedPosts) {
        final localDate = post.createdAt.toLocal();
        final dateKey = _dateFormatter.format(localDate);
        final tag = _extractFirstTag(post.foodTag);

        final existing = postedTagByDate[dateKey];
        if (existing == null) {
          postedTagByDate[dateKey] = tag.isNotEmpty ? tag : _defaultFoodEmoji;
        } else if (existing == _defaultFoodEmoji && tag.isNotEmpty) {
          // 最新投稿にタグが無く、同日の別の投稿にタグがある場合はそちらを使う
          postedTagByDate[dateKey] = tag;
        }
      }

      // 当月（および前後）で使われているカスタムタグ画像を Base64 辞書として用意する
      final customTagIconsBase64 = <String, String>{};
      final postedEmojisByDate = <String, String>{};

      for (final entry in postedTagByDate.entries) {
        final dateKey = entry.key;
        final tag = entry.value;
        if (isCustomFoodTag(tag)) {
          final base64Icon = await _loadCustomTagIconBase64(tag);
          if (base64Icon != null && base64Icon.isNotEmpty) {
            customTagIconsBase64[tag] = base64Icon;
            postedEmojisByDate[dateKey] = tag;
          } else {
            postedEmojisByDate[dateKey] =
                _customTagFallbackEmoji[tag] ?? _defaultFoodEmoji;
          }
        } else {
          postedEmojisByDate[dateKey] = tag;
        }
      }

      final sortedDates = postedEmojisByDate.keys.toList()..sort();

      final payload = <String, dynamic>{
        'postedDates': sortedDates,
        'postedEmojis': postedEmojisByDate,
        'customTagIcons': customTagIconsBase64,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await HomeWidget.saveWidgetData<String>(
        payloadKey,
        jsonEncode(payload),
      );
      await HomeWidget.updateWidget(
        name: iosWidgetKind,
        iOSName: iosWidgetKind,
      );
    } on Exception catch (e, st) {
      _log.w(
        'CalendarHomeWidgetSync.syncFromPosts failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  static String _extractFirstTag(String foodTag) {
    if (foodTag.trim().isEmpty) {
      return '';
    }
    for (final raw in foodTag.split(',')) {
      final trimmed = raw.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return '';
  }

  /// `tag:xxx` に対応する `assets/tag/xxx.png` を小さくリサイズして Base64 化する。
  static Future<String?> _loadCustomTagIconBase64(String tagId) async {
    final cached = _customTagBase64Cache[tagId];
    if (cached != null) {
      return cached;
    }
    final assetPath = customFoodTagAssetPath(tagId);
    if (assetPath == null) {
      return null;
    }
    try {
      final byteData = await rootBundle.load(assetPath);
      final rawBytes = byteData.buffer.asUint8List();
      final decoded = img.decodeImage(rawBytes);
      final Uint8List pngBytes;
      if (decoded != null &&
          (decoded.width > _customTagIconDimension ||
              decoded.height > _customTagIconDimension)) {
        final resized = img.copyResize(
          decoded,
          width: _customTagIconDimension,
          height: _customTagIconDimension,
          interpolation: img.Interpolation.average,
        );
        pngBytes = Uint8List.fromList(img.encodePng(resized));
      } else {
        pngBytes = rawBytes;
      }
      final encoded = base64Encode(pngBytes);
      _customTagBase64Cache[tagId] = encoded;
      return encoded;
    } on Object catch (e, st) {
      _log.w(
        'CalendarHomeWidgetSync custom tag load failed ($tagId)',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
