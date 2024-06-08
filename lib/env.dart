import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MAPBOX', obfuscate: true)
  static final String mapbox = _Env.mapbox;

  @EnviedField(varName: 'IOS_AUTH_KEY', obfuscate: true)
  static final String iOSAuthKey = _Env.iOSAuthKey;
  @EnviedField(varName: 'ANDROID_AUTH_KEY', obfuscate: true)
  static final String androidAuthKey = _Env.androidAuthKey;
  @EnviedField(varName: 'WEB_AUTH_KEY', obfuscate: true)
  static final String webAuthKey = _Env.webAuthKey;
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
