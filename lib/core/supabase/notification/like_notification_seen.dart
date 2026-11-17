import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/notification/repository/notification_repository.dart';

/// 既読時刻より新しいいいねがあるか。
/// [seenAtReady] が false の間は未読扱いにしない。
bool hasUnseenLikeTimes({
  required List<DateTime>? likeTimes,
  required DateTime? seenAt,
  required bool seenAtReady,
}) {
  if (!seenAtReady || likeTimes == null || likeTimes.isEmpty) {
    return false;
  }
  if (seenAt == null) {
    return true;
  }
  final seen = seenAt.toUtc();
  return likeTimes.any((time) => time.toUtc().isAfter(seen));
}

/// 通知一覧を見終わった時刻。アカウントごとに SharedPreferences へ残す。
final likeNotificationSeenAtProvider =
    AsyncNotifierProvider<LikeNotificationSeenAt, DateTime?>(
  LikeNotificationSeenAt.new,
);

class LikeNotificationSeenAt extends AsyncNotifier<DateTime?> {
  @override
  Future<DateTime?> build() async {
    final userId = ref.watch(currentUserProvider);
    if (userId == null) {
      return null;
    }
    return Preference().getLikeNotificationsSeenAt(userId);
  }

  Future<void> markSeen(Iterable<DateTime> likeTimes) async {
    if (likeTimes.isEmpty) {
      return;
    }
    final userId = ref.read(currentUserProvider);
    if (userId == null) {
      return;
    }
    final latest = likeTimes.reduce(
      (current, next) => next.toUtc().isAfter(current.toUtc()) ? next : current,
    );
    final saved = state.asData?.value;
    if (saved != null && !latest.toUtc().isAfter(saved.toUtc())) {
      return;
    }
    final seenAt = latest.toUtc();
    await Preference().setLikeNotificationsSeenAt(userId, seenAt);
    if (!ref.mounted || ref.read(currentUserProvider) != userId) {
      return;
    }
    state = AsyncData(seenAt);
  }
}

final hasUnseenLikeNotificationsProvider = Provider<bool>((ref) {
  final notifications = ref.watch(myLikeNotificationsProvider);
  final seen = ref.watch(likeNotificationSeenAtProvider);
  return hasUnseenLikeTimes(
    likeTimes: notifications.asData?.value
        .map((notification) => notification.updatedAt)
        .toList(),
    seenAt: seen.asData?.value,
    seenAtReady: seen.hasValue,
  );
});
