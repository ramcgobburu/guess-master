import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/predict_screen.dart';
import 'screens/my_predictions_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/admin_enter_result_screen.dart';
import 'screens/admin_groups_screen.dart';
import 'screens/forgot_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://reznesnljluqtapihbkh.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJlem5lc25samx1cXRhcGloYmtoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0ODA4NzQsImV4cCI6MjA5MDA1Njg3NH0.Ja3kTTvhk4E3S2hsA0hE51msvJD-D65BIpqyTKVYyF4',
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
        '/home': (context) => _AuthGuard(child: const HomeScreen()),
        '/predict': (context) => _AuthGuard(child: const PredictScreen()),
        '/my-predictions': (context) => _AuthGuard(child: const MyPredictionsScreen()),
        '/leaderboard': (context) => _AuthGuard(child: const LeaderboardScreen()),
        '/admin': (context) => _AuthGuard(child: const AdminScreen()),
        '/admin-enter-result': (context) => _AuthGuard(child: const AdminEnterResultScreen()),
        '/admin-groups': (context) => _AuthGuard(child: const AdminGroupsScreen()),
      },
    );
  }
}

class _AuthGuard extends StatelessWidget {
  final Widget child;
  const _AuthGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentOrange),
        ),
      );
    }
    return child;
  }
}
