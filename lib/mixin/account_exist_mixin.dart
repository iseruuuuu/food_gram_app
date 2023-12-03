import 'dart:async';
import 'package:food_gram_app/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

mixin AccountExistMixin {
  Future<bool> doesAccountExist() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return false;
    }
    final response =
        await supabase.from('users').select().eq('user_id', user.id).execute();
    print(response.data);
    if (response.data != null && response.data.isNotEmpty) {
      return true;
    }
    return false;
  }

  Future<bool> loginStatus() async {
    final completer = Completer<bool>();
    Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      if (state.event == AuthChangeEvent.signedIn) {
        completer.complete(true);
      } else {
        completer.complete(false);
      }
    });
    return completer.future;
  }
}
