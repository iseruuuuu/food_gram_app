import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'friend_service.g.dart';

@riverpod
class FriendService extends _$FriendService {
  final _preference = Preference();
  final logger = Logger();

  String get _currentUserId {
    final userId = ref.read(currentUserProvider);
    if (userId == null) {
      throw Exception('User is not logged in');
    }
    return userId;
  }

  SupabaseClient get supabase => ref.read(supabaseProvider);

  @override
  Future<void> build() async {}

  /// 入力コードを trim + 大文字化する（DB の friend_code 形式に合わせる）
  String normalizeFriendCode(String raw) => raw.trim().toUpperCase();

  /// 現在アカウントに紐づくフレンドの user_id 一覧
  Future<List<String>> getFriendUserIds() async {
    final userId = _currentUserId;
    await _migrateLegacyFriendListIfNeeded(userId);
    final ids = await _preference.getStringListForUser(
      PreferenceKey.friendList,
      userId,
    );
    return ids.where((id) => id.isNotEmpty).toList();
  }

  /// friend_code からユーザー行を1件取得（なければ null）。
  /// [rawCode] を渡し、正規化ヒットしなければ trim のみの互換フォールバックを試す。
  Future<Map<String, dynamic>?> findUserByFriendCode(String rawCode) async {
    final normalized = normalizeFriendCode(rawCode);
    if (normalized.isEmpty) {
      return null;
    }
    final byNormalized = await _lookupByFriendCode(normalized);
    if (byNormalized != null) {
      return byNormalized;
    }
    final trimmed = rawCode.trim();
    if (trimmed.isEmpty || trimmed == normalized) {
      return null;
    }
    return _lookupByFriendCode(trimmed);
  }

  /// SharedPreferences にフレンドの user_id を追加する。
  /// 追加したら true、既に登録済みなら false。
  Future<bool> insertFriend({required String friendUserId}) async {
    await _migrateLegacyFriendListIfNeeded(_currentUserId);
    var added = false;
    await _preference.updateStringListForUser(
      PreferenceKey.friendList,
      _currentUserId,
      (current) {
        final ids = current.where((id) => id.isNotEmpty).toList();
        if (ids.contains(friendUserId)) {
          return ids;
        }
        added = true;
        return [...ids, friendUserId];
      },
    );
    return added;
  }

  /// 端末全体の旧キーを、初回アクセスしたアカウントへ移行して削除する。
  Future<void> _migrateLegacyFriendListIfNeeded(String userId) async {
    final legacy = await _preference.getStringList(PreferenceKey.friendList);
    if (legacy.isEmpty) {
      return;
    }
    final scoped = await _preference.getStringListForUser(
      PreferenceKey.friendList,
      userId,
    );
    if (scoped.isEmpty) {
      await _preference.updateStringListForUser(
        PreferenceKey.friendList,
        userId,
        (current) {
          final existing = current.where((id) => id.isNotEmpty).toList();
          if (existing.isNotEmpty) {
            return existing;
          }
          return legacy.where((id) => id.isNotEmpty).toList();
        },
      );
    }
    await _preference.remove(PreferenceKey.friendList);
  }

  Future<Map<String, dynamic>?> _lookupByFriendCode(String code) async {
    final rows = await supabase
        .from('users')
        .select()
        .eq('friend_code', code)
        .limit(2);
    if (rows.isEmpty) {
      return null;
    }
    if (rows.length > 1) {
      logger.w('Duplicate friend_code values exist for "$code"');
    }
    return Map<String, dynamic>.from(rows.first as Map);
  }
}
