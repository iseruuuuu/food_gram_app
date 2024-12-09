import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
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
}

@Envied(path: '.env.dev')
abstract class Dev {
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Dev.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Dev.supabaseAnonKey;
}

@Envied(path: '.env.prod')
abstract class Prod {
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _Prod.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _Prod.supabaseAnonKey;
}
