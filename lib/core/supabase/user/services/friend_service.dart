import 'package:food_gram_app/core/local/shared_preference.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'friend_service.g.dart';

@riverpod
class FriendService extends _$FriendService {
  final _preference = Preference();

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

  /// ローカルに保存しているフレンドの user_id 一覧
  Future<List<String>> getFriendUserIds() async {
    final ids = await _preference.getStringList(PreferenceKey.friendList);
    return ids.where((id) => id.isNotEmpty).toList();
  }

  /// friend_code からユーザー行を1件取得（なければ null）
  Future<Map<String, dynamic>?> findUserByFriendCode(String friendCode) async {
    final normalized = normalizeFriendCode(friendCode);
    final byNormalized = await supabase
        .from('users')
        .select()
        .eq('friend_code', normalized)
        .maybeSingle();
    if (byNormalized != null) {
      return byNormalized;
    }
    final trimmed = friendCode.trim();
    if (trimmed.isEmpty || trimmed == normalized) {
      return null;
    }
    return supabase
        .from('users')
        .select()
        .eq('friend_code', trimmed)
        .maybeSingle();
  }

  /// すでにフレンドかどうか（ローカル保存）
  Future<bool> isAlreadyFriend(String friendUserId) async {
    final ids = await getFriendUserIds();
    return ids.contains(friendUserId);
  }

  /// SharedPreferences にフレンドの user_id を追加する
  Future<void> insertFriend({required String friendUserId}) async {
    final ids = await getFriendUserIds();
    if (ids.contains(friendUserId)) {
      return;
    }
    await _preference.setStringList(
      PreferenceKey.friendList,
      [...ids, friendUserId],
    );
  }
}
