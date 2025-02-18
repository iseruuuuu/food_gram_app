import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'current_user_provider.g.dart';

@Riverpod(keepAlive: true)
SupabaseClient supabase(Ref ref) {
  return Supabase.instance.client;
}

@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  String? _cachedUserId;

  @override
  String? build() {
    // キャッシュがある場合はそれを返す
    if (_cachedUserId != null) {
      return _cachedUserId;
    }

    // キャッシュがない場合はSupabaseから取得して返す
    return _cachedUserId = ref.read(supabaseProvider).auth.currentUser?.id;
  }

  String? get value => state;

  // ログイン時に更新
  void update() {
    _cachedUserId = ref.read(supabaseProvider).auth.currentUser?.id;
    state = _cachedUserId;
  }

  // ログアウト時にクリア
  void clear() {
    _cachedUserId = null;
    state = null;
  }
}
