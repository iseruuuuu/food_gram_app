import 'package:flutter/material.dart';
import 'package:food_gram_app/screen/authentication/authentication_screen.dart';
import 'package:food_gram_app/screen/authentication/new_account_screen.dart';
import 'package:food_gram_app/screen/tab/tab_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }
    final session = supabase.auth.currentSession;
    if (session == null) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(),
        ),
      );
    } else if (!await doesAccountExist()) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewAccountScreen(),
        ),
      );
    } else {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TabScreen(),
        ),
      );
    }
  }

  Future<bool> doesAccountExist() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return false;
      }
      final response = await supabase
          .from('users')
          .select()
          .eq('user_id', user.id)
          .execute();
      final data = response.data;
      if (data is List && data.isEmpty) {
        return false;
      }
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/loading/loading.gif'),
          fit: BoxFit.cover,
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}
