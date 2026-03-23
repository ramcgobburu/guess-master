import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/predict_screen.dart';
import 'screens/my_predictions_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/admin_enter_result_screen.dart';
import 'screens/forgot_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://qiigwshlzdlvddcaknyp.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpaWd3c2hsemRsdmRkY2FrbnlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1NDI4MjgsImV4cCI6MjA3ODExODgyOH0.0cG3OQON4pQkFRV6BLBmuU3ruOOY8UZNb156CtHpEe8',
    );
  } catch (e) {
    debugPrint('Supabase init failed: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const GuessMasterApp());
}

final supabase = Supabase.instance.client;

class GuessMasterApp extends StatelessWidget {
  const GuessMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/predict': (context) => const PredictScreen(),
        '/my-predictions': (context) => const MyPredictionsScreen(),
        '/leaderboard': (context) => const LeaderboardScreen(),
        '/admin': (context) => const AdminScreen(),
        '/admin-enter-result': (context) => const AdminEnterResultScreen(),
      },
    );
  }
}
