import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<AuthState> authState(Ref ref) {
  final supabase = ref.read(supabaseProvider);
  return supabase.auth.onAuthStateChange;
}
