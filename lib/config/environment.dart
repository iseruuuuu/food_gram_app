import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  String get fileName => kReleaseMode ? '.env.prod' : '.env.dev';

  String get supabaseUrl => dotenv.env['SUPABASE_URL']!;

  String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;
}
