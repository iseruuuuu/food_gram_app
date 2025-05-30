import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/env.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(Ref ref) => AuthService(ref);

class AuthService {
  AuthService(this.ref);

  final logger = Logger();

  final Ref ref;

  SupabaseClient get supabase => ref.read(supabaseProvider);

  Future<Result<AuthResponse, String>> loginApple() async {
    try {
      final rawNonce = supabase.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
      final credential = await _getAppleCredential(hashedNonce);
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException('Apple ID token is null');
      }
      final authResponse = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );
      return Success(authResponse);
    } on AuthException catch (authError) {
      logger.e('Apple login failed: ${authError.message}');
      return Failure(authError.message);
    }
  }

  Future<AuthorizationCredentialAppleID> _getAppleCredential(String nonce) {
    return SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
  }

  Future<Result<AuthResponse, String>> loginGoogle() async {
    try {
      final googleSignIn = _getGoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign in was cancelled');
      }
      final googleAuth = await googleUser.authentication;
      final tokens = await _validateGoogleTokens(googleAuth);

      final authResponse = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: tokens.idToken,
        accessToken: tokens.accessToken,
      );
      return Success(authResponse);
    } on AuthException catch (authError) {
      logger.e('Google login failed: ${authError.message}');
      return Failure(authError.message);
    }
  }

  GoogleSignIn _getGoogleSignIn() {
    return GoogleSignIn(
      clientId: Env.iOSAuthKey,
      serverClientId: Env.webAuthKey,
      scopes: ['email'],
    );
  }

  Future<({String accessToken, String idToken})> _validateGoogleTokens(
    GoogleSignInAuthentication auth,
  ) async {
    final accessToken = auth.accessToken;
    final idToken = auth.idToken;

    if (accessToken == null) {
      throw const AuthException('No Google Access Token found');
    }
    if (idToken == null) {
      throw const AuthException('No Google ID Token found');
    }

    return (accessToken: accessToken, idToken: idToken);
  }

  Future<Result<bool, String>> loginTwitter() async {
    try {
      final authResponse = await supabase.auth.signInWithOAuth(
        OAuthProvider.twitter,
        redirectTo: 'com.foodgram.scheme://auth/callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      return Success(authResponse);
    } on AuthException catch (authError) {
      logger.e('Twitter login failed: ${authError.message}');
      return Failure(authError.message);
    }
  }

  Future<Result<void, Exception>> signOut() async {
    try {
      await supabase.auth.signOut();
      return const Success(null);
    } on AuthException catch (error) {
      logger.e('Sign out failed: $error');
      return Failure(error);
    } on Exception catch (error) {
      logger.e('Unexpected error during sign out: $error');
      return Failure(error);
    }
  }
}
