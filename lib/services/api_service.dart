import '../main.dart';
import '../models/match.dart';
import '../models/prediction.dart';
import '../models/leaderboard_entry.dart';
import '../models/actual.dart';

class ApiService {
  static Future<List<Match>> getActiveMatches() async {
    final now = DateTime.now().toUtc();
    final response = await supabase
        .from('matches')
        .select()
        .eq('is_locked', false)
        .gte('start_date_time', now.toIso8601String())
        .order('start_date_time');

    return (response as List).map((json) => Match.fromSupabase(json)).toList();
  }

  static Future<List<Match>> getAllMatches() async {
    final response = await supabase
        .from('matches')
        .select()
        .order('start_date_time');

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

  static Future<List<LeaderboardEntry>> getLeaderboard() async {
    final response = await supabase.rpc('get_leaderboard');
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
}
