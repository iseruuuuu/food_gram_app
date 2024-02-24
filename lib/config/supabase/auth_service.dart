import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:food_gram_app/constants/api_key.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/model/result.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(AuthServiceRef ref) => AuthService();

class AuthService {
  AuthService();

  Future<Result<void, Exception>> login(String email) async {
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

  Future<Result<AuthResponse, Exception>> loginApple() async {
    try {
      final rawNonce = supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException('idToken is null');
      }
      final signInWithIdToken = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      return Success(signInWithIdToken);
    } on AuthException catch (authError) {
      return Failure(authError);
    }
  }

  Future<Result<AuthResponse, Exception>> loginGoogle() async {
    try {
      const iosClientId = GoogleAuthKey.iOSAuthKey;
      final googleSignIn = GoogleSignIn(clientId: iosClientId);
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      if (accessToken == null) {
        throw const AuthException('No Access Token found');
      }
      if (idToken == null) {
        throw const AuthException('No ID Token found');
      }
      final signInWithIdToken = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      return Success(signInWithIdToken);
    } on AuthException catch (authError) {
      logger.e(authError);
      return Failure(authError);
    }
  }

  Future<Result<void, Exception>> signOut() async {
    try {
      await supabase.auth.signOut();
      return const Success(null);
    } on AuthException catch (error) {
      logger.e(error);
      return Failure(error);
    } on Exception catch (error) {
      logger.e(error.toString());
      return Failure(error);
    }
  }
}
