import 'dart:convert';

/// 投稿数ランキングの日次スナップショット。キーはローカル日付の `yyyy-MM-dd`。
class PostRankHistory {
  const PostRankHistory(this.days);

  factory PostRankHistory.decode(String raw) {
    if (raw.isEmpty) {
      return const PostRankHistory({});
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return const PostRankHistory({});
      }
      final history = <String, int>{};
      for (final entry in decoded.entries) {
        final key = entry.key;
        final date = _parseDateKey(key is String ? key : '');
        final rank = _positiveRank(entry.value);
        if (date == null || rank == null) {
          continue;
        }
        history[_dateKey(date)] = rank;
      }
      return PostRankHistory(history);
    } on Object {
      return const PostRankHistory({});
    }
  }

  /// 先月比に必要な期間を残しつつ、古い日付は捨てる。
  static const retentionDays = 400;

  final Map<String, int> days;

  String encode() => jsonEncode(days);

  /// 今日の順位を上書き保存する。同日に何度開いてもその日の最新順位になる。
  PostRankHistory record({
    required DateTime today,
    required int rank,
  }) {
    final todayDate = _dateOnly(today);
    final cutoff = todayDate.subtract(const Duration(days: retentionDays));
    final next = <String, int>{};
    for (final entry in days.entries) {
      final date = _parseDateKey(entry.key);
      if (date == null || date.isBefore(cutoff) || entry.value < 1) {
        continue;
      }
      next[_dateKey(date)] = entry.value;
    }
    if (rank >= 1) {
      next[_dateKey(todayDate)] = rank;
    }
    return PostRankHistory(next);
  }

  /// プラスは順位上昇（数字が小さくなった）、マイナスは下降。
  /// 比べる記録がまだ無いときは null。
  PostRankComparison compare({
    required int currentRank,
    required DateTime today,
  }) {
    final todayDate = _dateOnly(today);
    final previousMonth = DateTime(todayDate.year, todayDate.month - 1);
    DateTime? latestDay;
    var dayRank = 0;
    DateTime? latestMonth;
    var monthRank = 0;

    for (final entry in days.entries) {
      final date = _parseDateKey(entry.key);
      if (date == null || !date.isBefore(todayDate)) {
        continue;
      }
      if (latestDay == null || date.isAfter(latestDay)) {
        latestDay = date;
        dayRank = entry.value;
      }
      final inPreviousMonth =
          date.year == previousMonth.year && date.month == previousMonth.month;
      if (inPreviousMonth &&
          (latestMonth == null || date.isAfter(latestMonth))) {
        latestMonth = date;
        monthRank = entry.value;
      }
    }

    return PostRankComparison(
      currentRank: currentRank,
      dayDelta: latestDay == null ? null : dayRank - currentRank,
      monthDelta: latestMonth == null ? null : monthRank - currentRank,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  static String _dateKey(DateTime date) {
    final local = _dateOnly(date);
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  static DateTime? _parseDateKey(String key) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(key);
    if (match == null) {
      return null;
    }
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  static int? _positiveRank(Object? value) {
    final rank = switch (value) {
      final int number => number,
      final num number => number.toInt(),
      _ => null,
    };
    if (rank == null || rank < 1) {
      return null;
    }
    return rank;
  }
}

class PostRankComparison {
  const PostRankComparison({
    required this.currentRank,
    required this.dayDelta,
    required this.monthDelta,
  });

  final int currentRank;

  /// プラスは順位上昇。比べる日が無いときは null。
  final int? dayDelta;

  /// プラスは順位上昇。先月の記録が無いときは null。
  final int? monthDelta;

  bool get hasNoBaseline => dayDelta == null && monthDelta == null;
}
