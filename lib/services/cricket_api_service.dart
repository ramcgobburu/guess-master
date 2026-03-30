import 'dart:convert';
import 'package:http/http.dart' as http;

const _cricDataApiKey = '6a4a44f1-f226-4423-b7ef-b2509a6af802';
const _espnLeagueId = '8048';

const _teamNameMap = <String, String>{
  'chennai super kings': 'CSK',
  'mumbai indians': 'MI',
  'royal challengers bengaluru': 'RCB',
  'royal challengers bangalore': 'RCB',
  'kolkata knight riders': 'KKR',
  'sunrisers hyderabad': 'SRH',
  'rajasthan royals': 'RR',
  'delhi capitals': 'DC',
  'punjab kings': 'PBKS',
  'lucknow super giants': 'LSG',
  'gujarat titans': 'GT',
};

String _mapTeam(String name) {
  return _teamNameMap[name.toLowerCase().trim()] ?? name.toUpperCase().trim();
}

class FetchedResult {
  final String tossWinner;
  final String matchWinner;
  final int firstInningsScore;
  final int totalWickets;
  final int highestScore;
  final bool highestScoreTied;
  final String momTeam;

  FetchedResult({
    required this.tossWinner,
    required this.matchWinner,
    required this.firstInningsScore,
    required this.totalWickets,
    required this.highestScore,
    required this.highestScoreTied,
    required this.momTeam,
  });
}

class CricketApiService {
  static Future<FetchedResult> fetchMatchResult({
    required String cricApiId,
    required String espnEventId,
  }) async {
    final results = await Future.wait([
      _fetchCricDataScorecard(cricApiId),
      _fetchEspnData(espnEventId),
    ]);

    final cric = results[0] as _CricData?;
    final espn = results[1] as _EspnData?;

    if (cric == null) throw Exception('CricData API failed. Try again later.');
    if (espn == null) throw Exception('ESPN API failed. Try again later.');
    if (!espn.matchEnded) throw Exception('Match has not ended yet.');

    return FetchedResult(
      tossWinner: cric.tossWinner.isNotEmpty ? cric.tossWinner : espn.tossWinner,
      matchWinner: espn.matchWinner.isNotEmpty ? espn.matchWinner : cric.matchWinner,
      firstInningsScore: cric.firstInningsScore,
      totalWickets: cric.totalWickets,
      highestScore: cric.highestScore,
      highestScoreTied: cric.highestScoreTied,
      momTeam: espn.momTeam,
    );
  }

  static Future<_CricData?> _fetchCricDataScorecard(String cricId) async {
    try {
      final url = Uri.parse(
        'https://api.cricapi.com/v1/match_scorecard?apikey=$_cricDataApiKey&id=$cricId',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body);
      if (json['status'] == 'failure' || json['data'] == null) return null;

      final data = json['data'];
      final tossWinner = _mapTeam((data['tossWinner'] ?? '') as String);
      final matchWinner = _mapTeam((data['matchWinner'] ?? '') as String);

      final scores = (data['score'] as List?) ?? [];
      final firstInningsScore = scores.isNotEmpty ? (scores[0]['r'] ?? 0) as int : 0;
      int totalWickets = 0;
      for (final s in scores) {
        totalWickets += (s['w'] ?? 0) as int;
      }

      int highestScore = 0;
      bool highestScoreTied = false;
      final allRuns = <int>[];
      final scorecard = (data['scorecard'] as List?) ?? [];
      for (final inning in scorecard) {
        final batting = (inning['batting'] as List?) ?? [];
        for (final b in batting) {
          allRuns.add((b['r'] ?? 0) as int);
        }
      }
      if (allRuns.isNotEmpty) {
        highestScore = allRuns.reduce((a, b) => a > b ? a : b);
        highestScoreTied = allRuns.where((r) => r == highestScore).length >= 2;
      }

      return _CricData(
        tossWinner: tossWinner,
        matchWinner: matchWinner,
        firstInningsScore: firstInningsScore,
        totalWickets: totalWickets,
        highestScore: highestScore,
        highestScoreTied: highestScoreTied,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<_EspnData?> _fetchEspnData(String espnId) async {
    try {
      final url = Uri.parse(
        'https://site.api.espn.com/apis/site/v2/sports/cricket/$_espnLeagueId/summary?event=$espnId',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body);
      final header = json['header'] ?? {};
      final comp = ((header['competitions'] as List?) ?? []).isNotEmpty
          ? (header['competitions'] as List)[0]
          : null;
      if (comp == null) return null;

      final status = comp['status'] ?? {};
      final stateType = status['type'] ?? {};
      final isComplete = stateType['state'] == 'post' || stateType['detail'] == 'Final';
      if (!isComplete) return _EspnData(tossWinner: '', matchWinner: '', momTeam: '', matchEnded: false);

      // Winner
      String matchWinner = '';
      final teamMap = <String, String>{};
      for (final c in (comp['competitors'] as List?) ?? []) {
        final abbr = (c['team']?['abbreviation'] ?? '') as String;
        teamMap[(c['team']?['id'] ?? '').toString()] = _mapTeam(abbr);
        if (c['winner'] == true) matchWinner = _mapTeam(abbr);
      }

      // Toss
      String tossWinner = '';
      for (final n in (json['notes'] as List?) ?? []) {
        if (n['type'] == 'toss') {
          final text = ((n['text'] ?? '') as String).toLowerCase();
          for (final entry in _teamNameMap.entries) {
            if (text.contains(entry.key)) {
              tossWinner = entry.value;
              break;
            }
          }
          break;
        }
      }

      // MOM
      String momTeam = '';
      for (final fa in (status['featuredAthletes'] as List?) ?? []) {
        if (fa['name'] == 'playerOfTheMatch') {
          final faTeamId = (fa['team']?['id'] ?? '').toString();
          momTeam = teamMap[faTeamId] ?? _mapTeam((fa['team']?['name'] ?? '') as String);
          break;
        }
      }

      return _EspnData(
        tossWinner: tossWinner,
        matchWinner: matchWinner,
        momTeam: momTeam,
        matchEnded: true,
      );
    } catch (_) {
      return null;
    }
  }
}

class _CricData {
  final String tossWinner, matchWinner;
  final int firstInningsScore, totalWickets, highestScore;
  final bool highestScoreTied;
  _CricData({
    required this.tossWinner,
    required this.matchWinner,
    required this.firstInningsScore,
    required this.totalWickets,
    required this.highestScore,
    required this.highestScoreTied,
  });
}

class _EspnData {
  final String tossWinner, matchWinner, momTeam;
  final bool matchEnded;
  _EspnData({
    required this.tossWinner,
    required this.matchWinner,
    required this.momTeam,
    required this.matchEnded,
  });
}
