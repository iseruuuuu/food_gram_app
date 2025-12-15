# Authentication Implementation Guide

This document explains how authentication is implemented in Food Gram.

## Overview

Food Gram App uses Supabase Auth to implement authentication. It supports Google Sign-In, Apple Sign-In, and Twitter Sign-In.

## Technology Stack

- **Supabase Auth**: Authentication foundation
- **google_sign_in**: Google Sign-In (v6.1.4)
- **sign_in_with_apple**: Apple Sign-In (v7.0.1)
- **crypto**: Security (nonce generation)

## Architecture

### Directory Structure

```
lib/
├── core/supabase/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_state_provider.dart    # Authentication state provider
│   │   └── services/
│   │       ├── auth_service.dart          # Authentication service implementation
│   │       └── account_service.dart        # Account management service
│   └── current_user_provider.dart         # Current user provider
└── ui/screen/authentication/
    ├── authentication_screen.dart          # Authentication screen
    ├── authentication_view_model.dart      # Authentication screen state management
    └── authentication_state.dart           # Authentication screen state definition
```

## Authentication Flow

### 1. Authentication Screen Display

When the app launches, if the user is not authenticated, the authentication screen is displayed:

```dart
class AuthenticationScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Monitor authentication state
    final authStateSubscription = useMemoized(
      () => supabase.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null && !hasNavigatedRef.value) {
          hasNavigatedRef.value = true;
          redirect(context, ref);
        }
      }),
    );
    // ...
  }
}
```

### 2. Authentication Method Selection

Users can choose from the following authentication methods:

- **Apple Sign-In**: iOS devices only
- **Google Sign-In**: iOS/Android compatible
- **Twitter Sign-In**: OAuth authentication

## Authentication Implementation Details

### Google Sign-In

#### Implementation

```dart
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
```

#### Google Sign-In Configuration

Get client ID from environment variables:

```dart
GoogleSignIn _getGoogleSignIn() {
  return GoogleSignIn(
    clientId: Platform.isAndroid ? Env.androidAuthKey : Env.iOSAuthKey,
    serverClientId: Env.webAuthKey,
    scopes: ['email'],
  );
}
```

#### Required Environment Variables

- `IOS_AUTH_KEY`: Google OAuth Client ID for iOS
- `ANDROID_AUTH_KEY`: Google OAuth Client ID for Android
- `WEB_AUTH_KEY`: Google OAuth Client ID for Web (serverClientId)

### Apple Sign-In

#### Implementation

```dart
Future<Result<AuthResponse, String>> loginApple() async {
  try {
    // Generate nonce (for security)
    final rawNonce = supabase.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    
    // Get Apple authentication credential
    final credential = await _getAppleCredential(hashedNonce);
    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException('Apple ID token is null');
    }
    
    // Authenticate with Supabase
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
```

#### Nonce Generation

For security, Apple Sign-In uses nonce:

```dart
final rawNonce = supabase.auth.generateRawNonce();
final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
```

#### Getting Apple Authentication Credential

```dart
Future<AuthorizationCredentialAppleID> _getAppleCredential(String nonce) {
  return SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: nonce,
  );
}
```

#### iOS Configuration

1. **Xcode Configuration**:
   - Add Sign in with Apple capability
   - Verify Bundle Identifier

2. **Apple Developer Portal**:
   - Enable Sign in with Apple for App ID
   - Create Service ID (if needed)

### Twitter Sign-In

#### Implementation

```dart
Future<Result<bool, String>> loginTwitter() async {
  try {
    final authResponse = await supabase.auth.signInWithOAuth(
      OAuthProvider.twitter,
      redirectTo: 'com.foodgram.scheme://auth/callback',
      authScreenLaunchMode: LaunchMode.inAppBrowserView,
    );
    return Success(authResponse);
  } on AuthException catch (authError) {
    logger.e('Twitter login failed: ${authError.message}');
    return Failure(authError.message);
  }
}
```

#### Deep Link Configuration

For Twitter Sign-In, set the redirect destination after authentication:

```dart
redirectTo: 'com.foodgram.scheme://auth/callback'
```

## Authentication State Management

### Getting Current User

Manage current user with `CurrentUser` provider:

```dart
@Riverpod(keepAlive: true)
class CurrentUser extends _$CurrentUser {
  String? _cachedUserId;

  @override
  String? build() {
    if (_cachedUserId != null) {
      return _cachedUserId;
    }
    return _cachedUserId = ref.read(supabaseProvider).auth.currentUser?.id;
  }

  void update() {
    _cachedUserId = ref.read(supabaseProvider).auth.currentUser?.id;
    state = _cachedUserId;
  }

  void clear() {
    _cachedUserId = null;
    state = null;
  }
}
```

### Monitoring Authentication State

Monitor authentication state changes:

```dart
supabase.auth.onAuthStateChange.listen((data) {
  final session = data.session;
  if (session != null) {
    // Login successful
    redirect(context, ref);
  } else {
    // Logged out
  }
});
```

## Sign Out

### Implementation

```dart
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
```

### Post Sign-Out Processing

After sign out, redirect to authentication screen:

```dart
await ref.read(authServiceProvider).signOut();
// Redirect to authentication screen
```

## Error Handling

### Error Handling Implementation

Authentication errors are handled using `Result` type:

```dart
final result = await ref.read(authServiceProvider).loginGoogle();
await result.when(
  success: (_) async {
    // Login successful
    state = state.copyWith(loginStatus: L10n.of(context).loginSuccessful);
  },
  failure: (error) {
    // Error handling
    logger.e(error);
    SnackBarHelper().openErrorSnackBar(
      context,
      L10n.of(context).loginError,
      L10n.of(context).error,
    );
  },
);
```

## Security Considerations

### 1. Nonce Usage

Apple Sign-In uses nonce to prevent replay attacks:

```dart
final rawNonce = supabase.auth.generateRawNonce();
final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
```

### 2. Token Verification

Supabase automatically verifies ID tokens.

### 3. Session Management

Supabase automatically manages sessions and securely stores tokens.

## Supabase Configuration

### 1. Authentication Provider Configuration

Enable authentication providers in Supabase Dashboard:

1. Authentication → Providers
2. Enable Google, Apple, Twitter
3. Complete configuration for each provider

### 2. Redirect URL Configuration

Set redirect destination after authentication:

- `com.foodgram.scheme://auth/callback` (for Twitter)

### 3. OAuth Configuration

OAuth configuration for each provider:

- **Google**: Set OAuth 2.0 Client ID
- **Apple**: Set Service ID and Key ID
- **Twitter**: Set API Key and Secret

## Troubleshooting

### Google Sign-In Not Working

1. Verify `GoogleService-Info.plist` (iOS) or `google-services.json` (Android) is correctly placed
2. Verify OAuth 2.0 Client ID is correctly configured
3. Verify Bundle Identifier / Package Name matches

### Apple Sign-In Not Working

1. Enable Sign in with Apple in Apple Developer Portal
2. Add Capability in Xcode
3. Verify Bundle Identifier is correct

### Not Redirecting After Authentication

1. Verify authentication state monitoring is correctly configured
2. Verify redirect URL is correctly configured
3. Verify deep link configuration

## Links

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Sign in with Apple Flutter](https://pub.dev/packages/sign_in_with_apple)

