import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class AuthService {
  static User? get currentUser => supabase.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static String get userId => currentUser?.id ?? '';

  static String get userEmail => currentUser?.email ?? '';

  static String get userName =>
      currentUser?.userMetadata?['name'] as String? ??
      userEmail.split('@').first;

  static bool _isAdmin = false;
  static bool get isAdmin => _isAdmin;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    await _loadAdminStatus();
  }

  static Future<void> signOut() async {
    _isAdmin = false;
    await supabase.auth.signOut();
  }

  static Future<void> _loadAdminStatus() async {
    if (currentUser == null) {
      _isAdmin = false;
      return;
    }
    try {
      final profile = await supabase
          .from('profiles')
          .select('is_admin')
          .eq('id', currentUser!.id)
          .maybeSingle();
      _isAdmin = profile?['is_admin'] == true;
    } catch (_) {
      _isAdmin = false;
    }
  }

  static Future<void> refreshAdminStatus() async {
    await _loadAdminStatus();
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    if (currentUser == null) return null;
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();
    return response;
  }
}
