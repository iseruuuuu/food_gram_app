import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  const Env._();

  @EnviedField(varName: 'MAP_LIBRE', obfuscate: true)
  static final String mapLibre = _Env.mapLibre;
  @EnviedField(varName: 'HOT_PEPPER', obfuscate: true)
  static final String hotPepper = _Env.hotPepper;
  @EnviedField(varName: 'MAPBOX', obfuscate: true)
  static final String mapbox = _Env.mapbox;
  @EnviedField(varName: 'IOS_AUTH_KEY', obfuscate: true)
  static final String iOSAuthKey = _Env.iOSAuthKey;
  @EnviedField(varName: 'ANDROID_AUTH_KEY', obfuscate: true)
  static final String androidAuthKey = _Env.androidAuthKey;
  @EnviedField(varName: 'WEB_AUTH_KEY', obfuscate: true)
  static final String webAuthKey = _Env.webAuthKey;
  @EnviedField(varName: 'IOS_GOOGLE_APIKEY', obfuscate: true)
  static final String iOSGoogleApikey = _Env.iOSGoogleApikey;
  @EnviedField(varName: 'ANDROID_GOOGLE_APIKEY', obfuscate: true)
  static final String androidGoogleApikey = _Env.androidGoogleApikey;
  @EnviedField(varName: 'MASTER_ACCOUNT', obfuscate: true)
  static final String masterAccount = _Env.masterAccount;
  @EnviedField(varName: 'IOS_PURCHASE_KEY', obfuscate: true)
  static final String iOSPurchaseKey = _Env.iOSPurchaseKey;
  @EnviedField(varName: 'ANDROID_PURCHASE_KEY', obfuscate: true)
  static final String androidPurchaseKey = _Env.androidPurchaseKey;
  @EnviedField(varName: 'IOS_BANNER', obfuscate: true)
  static final String iOSBanner = _Env.iOSBanner;
  @EnviedField(varName: 'IOS_INTERSTITIAL', obfuscate: true)
  static final String iOSInterstitial = _Env.iOSInterstitial;
  @EnviedField(varName: 'IOS_OPEN', obfuscate: true)
  static final String iOSOpen = _Env.iOSOpen;
  @EnviedField(varName: 'ANDROID_BANNER', obfuscate: true)
  static final String androidBanner = _Env.androidBanner;
  @EnviedField(varName: 'ANDROID_INTERSTITIAL', obfuscate: true)
  static final String androidInterstitial = _Env.androidInterstitial;
  @EnviedField(varName: 'ANDROID_OPEN', obfuscate: true)
  static final String androidOpen = _Env.androidOpen;
  @EnviedField(varName: 'POINT', obfuscate: true)
  static final String point = _Env.point;
}

@Envied(path: '.env.dev')
abstract class Dev {
  const Dev._();

  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Dev.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Dev.supabaseAnonKey;
}

@Envied(path: '.env.prod')
abstract class Prod {
  const Prod._();

  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Prod.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Prod.supabaseAnonKey;
}
