class Prediction {
  final int? id;
  final String matchId;
  final String userId;
  final String email;
  final String name;
  final String tossWinner;
  final int score;
  final String matchWinner;
  final String mom;
  final int totalWickets;
  final int highestScore;
  final int points;
  final Map<String, dynamic>? pointsBreakdown;
  final DateTime? createdAt;

  Prediction({
    this.id,
    required this.matchId,
    required this.userId,
    required this.email,
    required this.name,
    required this.tossWinner,
    required this.score,
    required this.matchWinner,
    required this.mom,
    required this.totalWickets,
    required this.highestScore,
    this.points = 0,
    this.pointsBreakdown,
    this.createdAt,
  });

  factory Prediction.fromSupabase(Map<String, dynamic> json) {
    return Prediction(
      id: json['id'],
      matchId: json['match_id'] ?? '',
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      tossWinner: json['toss_winner'] ?? '',
      score: json['score'] ?? 0,
      matchWinner: json['match_winner'] ?? '',
      mom: json['mom'] ?? '',
      totalWickets: json['total_wickets'] ?? 0,
      highestScore: json['highest_score'] ?? 0,
      points: json['points'] ?? 0,
      pointsBreakdown: json['points_breakdown'] is Map
          ? Map<String, dynamic>.from(json['points_breakdown'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'match_id': matchId,
      'user_id': userId,
      'email': email,
      'name': name,
      'toss_winner': tossWinner,
      'score': score,
      'match_winner': matchWinner,
      'mom': mom,
      'total_wickets': totalWickets,
      'highest_score': highestScore,
    };
  }
}
