import 'package:food_gram_app/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.g.dart';

@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  return supabase.auth.onAuthStateChange;
}
