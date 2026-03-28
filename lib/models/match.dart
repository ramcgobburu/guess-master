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

  DateTime get lockTime => startDateTime.subtract(const Duration(minutes: 31));

  bool get hasStarted => DateTime.now().toUtc().isAfter(startDateTime);

  bool get isLockTimePassed => DateTime.now().toUtc().isAfter(lockTime);

  bool get canPredict {
    final now = DateTime.now().toUtc();
    return now.isBefore(lockTime) && !isLocked;
  }

  MatchStatus statusInContext(Match? previousMatch) {
    final now = DateTime.now().toUtc();

    if (now.isAfter(startDateTime)) return MatchStatus.completed;

    if (isLockTimePassed) return MatchStatus.locked;

    final isUnlocked = previousMatch == null || previousMatch.hasStarted;
    if (isUnlocked && canPredict) return MatchStatus.open;

    return MatchStatus.upcoming;
  }
}

enum MatchStatus { open, locked, completed, upcoming }
