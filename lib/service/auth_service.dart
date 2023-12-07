import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/model/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(AuthServiceRef ref) => AuthService();

class AuthService {
  AuthService();

  Future<Result<void, Exception>> logIn(String email) async {
    try {
      await supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
        emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
      return const Success(null);
    } on AuthException catch (authError) {
      return Failure(authError);
    } on Exception catch (error) {
      return Failure(error);
    }
  }
}
