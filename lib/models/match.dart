class Match {
  final int? id;
  final String matchId;
  final String team1;
  final String team2;
  final String date;
  final String time;
  final DateTime startDateTime;
  final bool isLocked;
  final String venue;

  Match({
    this.id,
    required this.matchId,
    required this.team1,
    required this.team2,
    required this.date,
    required this.time,
    required this.startDateTime,
    required this.isLocked,
    this.venue = '',
  });

  factory Match.fromSupabase(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      matchId: json['match_id'] ?? '',
      team1: json['team1'] ?? '',
      team2: json['team2'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      startDateTime: DateTime.parse(json['start_date_time']),
      isLocked: json['is_locked'] ?? false,
      venue: json['venue'] ?? '',
    );
  }

  bool get canPredict {
    final now = DateTime.now().toUtc();
    final lockTime = startDateTime.subtract(const Duration(minutes: 31));
    return now.isBefore(lockTime) && !isLocked;
  }
}
