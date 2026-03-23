class Actual {
  final int? id;
  final String matchId;
  final String tossWinner;
  final int score;
  final String matchWinner;
  final String mom;
  final int totalWickets;
  final int highestScore;
  final bool highestScoreTied;

  Actual({
    this.id,
    required this.matchId,
    required this.tossWinner,
    required this.score,
    required this.matchWinner,
    required this.mom,
    required this.totalWickets,
    required this.highestScore,
    this.highestScoreTied = false,
  });

  factory Actual.fromSupabase(Map<String, dynamic> json) {
    return Actual(
      id: json['id'],
      matchId: json['match_id'] ?? '',
      tossWinner: json['toss_winner'] ?? '',
      score: json['score'] ?? 0,
      matchWinner: json['match_winner'] ?? '',
      mom: json['mom'] ?? '',
      totalWickets: json['total_wickets'] ?? 0,
      highestScore: json['highest_score'] ?? 0,
      highestScoreTied: json['highest_score_tied'] ?? false,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'match_id': matchId,
      'toss_winner': tossWinner,
      'score': score,
      'match_winner': matchWinner,
      'mom': mom,
      'total_wickets': totalWickets,
      'highest_score': highestScore,
      'highest_score_tied': highestScoreTied,
    };
  }
}
