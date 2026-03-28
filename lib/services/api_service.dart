import '../main.dart';
import '../models/match.dart';
import '../models/prediction.dart';
import '../models/leaderboard_entry.dart';
import '../models/actual.dart';
import '../models/group.dart';
import '../services/auth_service.dart';

class ApiService {
  static Future<List<Match>> getActiveMatches() async {
    final now = DateTime.now().toUtc();
    final response = await supabase
        .from('matches')
        .select()
        .eq('is_locked', false)
        .gte('start_date_time', now.toIso8601String())
        .order('start_date_time', ascending: true);

    return (response as List).map((json) => Match.fromSupabase(json)).toList();
  }

  static Future<List<Match>> getAllMatches() async {
    final response = await supabase
        .from('matches')
        .select()
        .order('start_date_time', ascending: true);

    return (response as List).map((json) => Match.fromSupabase(json)).toList();
  }

  static Future<List<Prediction>> getMyPredictions(String userId) async {
    final response = await supabase
        .from('predictions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Prediction.fromSupabase(json))
        .toList();
  }

  static Future<void> submitPrediction(Prediction prediction) async {
    await supabase.from('predictions').upsert(
      prediction.toSupabase(),
      onConflict: 'match_id,user_id',
    );
  }

  static Future<List<LeaderboardEntry>> getLeaderboard({String? groupId}) async {
    final gid = groupId ?? AuthService.groupId;
    final response = await supabase.rpc(
      'get_leaderboard',
      params: gid != null ? {'p_group_id': gid} : {},
    );
    return (response as List)
        .map((json) => LeaderboardEntry.fromJson(json))
        .toList();
  }

  static Future<Prediction?> getExistingPrediction(
      String matchId, String userId) async {
    final response = await supabase
        .from('predictions')
        .select()
        .eq('match_id', matchId)
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Prediction.fromSupabase(response);
  }

  // --- Admin methods ---

  static Future<Actual?> getActual(String matchId) async {
    final response = await supabase
        .from('actuals')
        .select()
        .eq('match_id', matchId)
        .maybeSingle();

    if (response == null) return null;
    return Actual.fromSupabase(response);
  }

  static Future<void> submitActual(Actual actual) async {
    await supabase.from('actuals').upsert(
      actual.toSupabase(),
      onConflict: 'match_id',
    );
  }

  static Future<int> calculatePoints(String matchId) async {
    final response = await supabase.rpc(
      'calculate_match_points',
      params: {'p_match_id': matchId},
    );
    if (response is List && response.isNotEmpty) {
      return response[0]['predictions_scored'] ?? 0;
    }
    return 0;
  }

  static Future<int> getPredictionCountForMatch(String matchId) async {
    final response = await supabase
        .from('predictions')
        .select('id')
        .eq('match_id', matchId);
    return (response as List).length;
  }

  // --- Leaderboard details (per-match points split) ---

  static Future<List<Map<String, dynamic>>> getLeaderboardDetails(
      {String? groupId}) async {
    final gid = groupId ?? AuthService.groupId;
    final response = await supabase.rpc(
      'get_leaderboard_details',
      params: gid != null ? {'p_group_id': gid} : {},
    );
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  // --- Match entries (group-filtered, only after lock time) ---

  static Future<List<Map<String, dynamic>>> getMatchEntries(
      String matchId) async {
    final response = await supabase.rpc(
      'get_match_entries',
      params: {'p_match_id': matchId},
    );
    return List<Map<String, dynamic>>.from(response ?? []);
  }

  // --- Group methods ---

  static Future<List<Group>> getAllGroups() async {
    final response = await supabase
        .from('groups')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: true);
    return (response as List).map((json) => Group.fromSupabase(json)).toList();
  }

  static Future<Group?> getGroupByCode(String code) async {
    final response = await supabase
        .from('groups')
        .select()
        .eq('code', code)
        .eq('is_active', true)
        .maybeSingle();
    if (response == null) return null;
    return Group.fromSupabase(response);
  }

  static Future<void> createGroup({
    required String name,
    required String code,
  }) async {
    await supabase.from('groups').insert({
      'name': name,
      'code': code,
      'created_by': AuthService.userId,
    });
  }

  static Future<List<GroupStats>> getGroupStats() async {
    final response = await supabase.rpc('get_group_stats');
    return (response as List)
        .map((json) => GroupStats.fromJson(json))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final response = await supabase
        .from('profiles')
        .select('id, name, email')
        .eq('group_id', groupId)
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }
}
