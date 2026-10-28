import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/home_widget/calendar_day.dart';
import 'package:food_gram_app/core/supabase/post/providers/post_stream_provider.dart';
import 'package:food_gram_app/core/supabase/post/repository/detail_post_repository.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:logger/logger.dart';

/// 投稿カレンダーの日付タップを、その日の食事画面へつなぐ。
///
/// ウィジェットは App Group の `calendar_day_launch` に `yyyy-MM-dd` を書いて
/// アプリを開く。ログイン後に、その日の最新投稿の詳細を開く。
class CalendarDayLaunch {
  CalendarDayLaunch._();

  static final _log = Logger();

  /// `OpenCalendarDayIntent.storageKey` と同じ。
  static const launchKey = 'calendar_day_launch';

  static DateTime? pending;
  static GoRouter? _router;
  static WidgetRef? _ref;
  static StreamSubscription<Uri?>? _subscription;
  static Future<void>? _consumeInFlight;
  static var _started = false;

  static void start() {
    if (_started || !Platform.isIOS) {
      return;
    }
    _started = true;
    unawaited(reloadCalendarWidget());
    unawaited(consumeStoredLaunch());
    _subscription = HomeWidget.widgetClicked.listen(
      (uri) {
        final day = parseCalendarDayLink(uri);
        if (day != null) {
          _remember(day);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        _log.w(
          'Calendar widget click stream failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
    unawaited(_loadInitial());
  }

  static void attach(GoRouter router, WidgetRef ref) {
    _ref = ref;
    if (identical(_router, router)) {
      return;
    }
    _router?.routerDelegate.removeListener(_onRoute);
    _router = router;
    router.routerDelegate.addListener(_onRoute);
  }

  static void detach() {
    _router?.routerDelegate.removeListener(_onRoute);
    _router = null;
    _ref = null;
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  /// ウィジェットが書いた日付を読み、あれば画面遷移を予約して消す。
  ///
  /// 起動時と前面復帰で同時に呼ばれても、読み取りは1本にまとめる。
  static Future<void> consumeStoredLaunch() {
    if (!Platform.isIOS) {
      return Future<void>.value();
    }
    final current = _consumeInFlight;
    if (current != null) {
      return current;
    }
    final future = _consumeStoredLaunchBody();
    _consumeInFlight = future;
    return future.whenComplete(() {
      if (identical(_consumeInFlight, future)) {
        _consumeInFlight = null;
      }
    });
  }

  static Future<void> _consumeStoredLaunchBody() async {
    for (var attempt = 0; attempt < 8; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      }
      final opened = await _readStoredLaunch();
      if (opened) {
        return;
      }
    }
    _log.i('calendar widget: stored day was empty');
  }

  static Future<void> reloadCalendarWidget() async {
    if (!Platform.isIOS) {
      return;
    }
    try {
      await HomeWidget.updateWidget(
        iOSName: 'PostCalendarWidget',
      );
    } on Object catch (error, stackTrace) {
      _log.w(
        'calendar widget reload failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<bool> _readStoredLaunch() async {
    try {
      final raw = await HomeWidget.getWidgetData<String>(launchKey);
      if (raw == null || raw.isEmpty) {
        return false;
      }
      _log.i('calendar widget stored day=$raw');
      final day = tryParseCalendarDayKey(raw);
      await HomeWidget.saveWidgetData<String>(launchKey, null);
      if (day == null) {
        return false;
      }
      _remember(day);
      return true;
    } on Object catch (error, stackTrace) {
      _log.w(
        'Calendar widget stored day read failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  static Future<void> _loadInitial() async {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      final day = parseCalendarDayLink(uri);
      if (day != null) {
        _remember(day);
      }
    } on Object catch (error, stackTrace) {
      _log.w(
        'Calendar widget initial link failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void _remember(DateTime day) {
    pending = DateTime(day.year, day.month, day.day);
    _scheduleOpen();
  }

  static void _onRoute() {
    if (pending == null) {
      return;
    }
    _scheduleOpen();
  }

  static void _scheduleOpen() {
    final router = _router;
    if (router == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = _router;
      if (current == null) {
        return;
      }
      openPendingCalendarDay(current);
    });
  }
}

/// ログイン後の画面なら、その日の最新投稿の詳細を開く。
void openPendingCalendarDay(GoRouter router) {
  final day = CalendarDayLaunch.pending;
  if (day == null) {
    return;
  }
  final path = _routerPath(router);
  const blocked = <String>{
    '/${RouterPath.splash}',
    '/${RouterPath.tutorial}',
    '/${RouterPath.authentication}',
    '/${RouterPath.registrationWelcome}',
  };
  if (blocked.contains(path)) {
    CalendarDayLaunch._log.i('calendar widget waiting on $path');
    return;
  }
  final ref = CalendarDayLaunch._ref;
  if (ref == null) {
    return;
  }
  CalendarDayLaunch.pending = null;
  unawaited(_openLatestPost(router, ref, day));
}

Future<void> _openLatestPost(
  GoRouter router,
  WidgetRef ref,
  DateTime day,
) async {
  final key = calendarDayKey(day);
  try {
    final posts = await ref.read(myPostStreamProvider.future);
    final dayPosts = postsOnCalendarDay(posts, day);
    if (dayPosts.isEmpty) {
      CalendarDayLaunch._log.i('calendar widget: no posts on $key');
      return;
    }
    final latest = dayPosts.first;
    final result = await ref
        .read(detailPostRepositoryProvider.notifier)
        .getPostData([latest], 0);
    final model = result.whenOrNull(success: (value) => value);
    if (model == null) {
      CalendarDayLaunch._log
          .w('calendar widget: post ${latest.id} load failed');
      return;
    }
    CalendarDayLaunch._log.i('calendar widget open post ${latest.id} on $key');
    await router.pushNamed(
      RouterPath.myProfileDetail,
      extra: model,
    );
  } on Object catch (error, stackTrace) {
    CalendarDayLaunch._log.w(
      'calendar widget open post failed',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

String _routerPath(GoRouter router) {
  final fromRoute = router.routeInformationProvider.value.uri.path;
  if (fromRoute.isNotEmpty) {
    return fromRoute;
  }
  final fromMatches = router.routerDelegate.currentConfiguration.uri.path;
  if (fromMatches.isNotEmpty) {
    return fromMatches;
  }
  return '';
}
