import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:food_gram_app/core/home_widget/calendar_day.dart';
import 'package:food_gram_app/core/home_widget/map_stats_home_widget_sync.dart';
import 'package:food_gram_app/core/model/food_tag_registry.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';

/// 投稿した日付と料理タグ（絵文字またはカスタムタグ画像）を
/// iOS ホームウィジェット（PostCalendarWidget）へ同期する。
///
/// ローカル日付の `yyyy-MM-dd` ごとに、その日の代表投稿の料理タグを
/// App Group（`group.com.FoodGram.ios`）の `UserDefaults` に保存し、
/// WidgetKit 側で当月のカレンダー上にスタンプを描画する。
/// 同じ日に複数あるときは件数も渡し、タップでその日の一覧を開けるようにする。
class CalendarHomeWidgetSync {
  CalendarHomeWidgetSync._();

  static final _log = Logger();

  static const String appGroupId = MapStatsHomeWidgetSync.appGroupId;
  static const iosWidgetKind = 'PostCalendarWidget';
  static const payloadKey = 'post_calendar_payload';

  static const _syncDebounceDuration = Duration(milliseconds: 500);
  static const _defaultFoodEmoji = '🍽️';
  static const _customTagIconDimension = 72;

  static final Map<String, String> _customTagBase64Cache = {};

  /// カスタムタグ画像が読み込めない場合や旧ウィジェット向けのフォールバック絵文字
  static const _customTagFallbackEmoji = <String, String>{
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
      final postsByDate = <String, List<Posts>>{};
      for (final post in posts) {
        postsByDate.putIfAbsent(calendarDayKey(post.createdAt), () => []).add(
              post,
            );
      }

      final postedTagByDate = <String, String>{};
      final postedCountByDate = <String, int>{};
      for (final entry in postsByDate.entries) {
        final dayPosts = List<Posts>.from(entry.value)
          ..sort(compareCalendarPostsNewestFirst);
        postedCountByDate[entry.key] = dayPosts.length;
        final representative = calendarDayRepresentative(dayPosts);
        final tag = representative == null
            ? ''
            : calendarDayFirstTag(representative.foodTag);
        postedTagByDate[entry.key] = tag.isNotEmpty ? tag : _defaultFoodEmoji;
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
        'postedCounts': postedCountByDate,
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
