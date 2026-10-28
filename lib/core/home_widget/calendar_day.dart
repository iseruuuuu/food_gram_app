import 'package:food_gram_app/core/model/posts.dart';

/// カレンダーウィジェットと「その日の食事」画面で共有する日付キー。
///
/// 端末のローカル日付で `yyyy-MM-dd` にする。投稿の `createdAt` が UTC でも、
/// ユーザーが見ている暦日と揃う。
String calendarDayKey(DateTime dateTime) {
  final local = dateTime.toLocal();
  final year = local.year.toString().padLeft(4, '0');
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// `yyyy-MM-dd` をローカル日付の 0 時として読む。存在しない日は null。
DateTime? tryParseCalendarDayKey(String raw) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw.trim());
  if (match == null) {
    return null;
  }
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (month < 1 || month > 12 || day < 1 || day > 31) {
    return null;
  }
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}

/// ウィジェットの `Link` から渡る URI を日付にする。
///
/// `com.foodgram.scheme://calendar-day?date=2026-10-28&homeWidget=1`
DateTime? parseCalendarDayLink(Uri? uri) {
  if (uri == null) {
    return null;
  }
  final segments = uri.pathSegments.where((segment) => segment.isNotEmpty);
  final dateParam = uri.queryParameters['date'];
  final hasWidgetMark = uri.queryParameters.containsKey('homeWidget');
  final isCalendarDay = uri.host == 'calendar-day' ||
      segments.contains('calendar-day') ||
      (hasWidgetMark && dateParam != null);
  if (!isCalendarDay) {
    return null;
  }
  if (dateParam != null && dateParam.isNotEmpty) {
    return tryParseCalendarDayKey(dateParam);
  }
  final path = segments.toList();
  if (uri.host == 'calendar-day' && path.length == 1) {
    return tryParseCalendarDayKey(path.first);
  }
  final index = path.indexOf('calendar-day');
  if (index >= 0 && index + 1 < path.length) {
    return tryParseCalendarDayKey(path[index + 1]);
  }
  return null;
}

/// 料理タグ文字列から、カレンダーに載せる先頭タグを取り出す。空なら空文字。
String calendarDayFirstTag(String foodTag) {
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

/// 新しい投稿を先にする。同時刻なら id が大きい方を先にする。
int compareCalendarPostsNewestFirst(Posts a, Posts b) {
  final created = b.createdAt.compareTo(a.createdAt);
  if (created != 0) {
    return created;
  }
  return b.id.compareTo(a.id);
}

/// ウィジェットのスタンプに使う投稿。
///
/// その日でいちばん新しい投稿の料理タグを優先する。最新投稿にタグが無いときだけ、
/// 同じ日のタグ付き投稿へ戻す。
Posts? calendarDayRepresentative(List<Posts> postsNewestFirst) {
  if (postsNewestFirst.isEmpty) {
    return null;
  }
  if (calendarDayFirstTag(postsNewestFirst.first.foodTag).isNotEmpty) {
    return postsNewestFirst.first;
  }
  for (final post in postsNewestFirst.skip(1)) {
    if (calendarDayFirstTag(post.foodTag).isNotEmpty) {
      return post;
    }
  }
  return postsNewestFirst.first;
}

/// [day] のローカル日付に記録された投稿。新しい順。
List<Posts> postsOnCalendarDay(List<Posts> posts, DateTime day) {
  final key = calendarDayKey(day);
  final matched = posts
      .where((post) => calendarDayKey(post.createdAt) == key)
      .toList()
    ..sort(compareCalendarPostsNewestFirst);
  return matched;
}
