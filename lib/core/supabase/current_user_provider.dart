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
  @override
  String? build() {
    return ref.read(supabaseProvider).auth.currentUser?.id;
  }

  String? get value => state;

  set value(String? userId) {
    state = userId;
  }

  // ログアウト時にクリア
  void clear() {
    state = null;
  }
}
