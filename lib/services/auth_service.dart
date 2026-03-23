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

  static String? _groupId;
  static String? get groupId => _groupId;

  static String _groupName = '';
  static String get groupName => _groupName;

  static String _groupCode = '';
  static String get groupCode => _groupCode;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String groupCode,
  }) async {
    final groupResponse = await supabase
        .from('groups')
        .select()
        .eq('code', groupCode)
        .eq('is_active', true)
        .maybeSingle();

    if (groupResponse == null) {
      throw Exception('Invalid group code. Please check and try again.');
    }

    final authResponse = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    if (authResponse.user != null) {
      await supabase.from('profiles').upsert({
        'id': authResponse.user!.id,
        'name': name,
        'email': email,
        'group_id': groupResponse['id'],
        'is_admin': false,
      }, onConflict: 'id');
    }

    return authResponse;
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    await _loadProfile();
  }

  static Future<void> signOut() async {
    _isAdmin = false;
    _groupId = null;
    _groupName = '';
    _groupCode = '';
    await supabase.auth.signOut();
  }

  static Future<void> _loadProfile() async {
    if (currentUser == null) {
      _isAdmin = false;
      _groupId = null;
      _groupName = '';
      _groupCode = '';
      return;
    }
    try {
      final profile = await supabase
          .from('profiles')
          .select('is_admin, group_id')
          .eq('id', currentUser!.id)
          .maybeSingle();
      _isAdmin = profile?['is_admin'] == true;
      _groupId = profile?['group_id'];

      if (_groupId != null) {
        final group = await supabase
            .from('groups')
            .select('name, code')
            .eq('id', _groupId!)
            .maybeSingle();
        _groupName = group?['name'] ?? '';
        _groupCode = group?['code'] ?? '';
      }
    } catch (_) {
      _isAdmin = false;
      _groupId = null;
    }
  }

  static Future<void> refreshProfile() async {
    await _loadProfile();
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
