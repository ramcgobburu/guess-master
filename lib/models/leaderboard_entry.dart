class LeaderboardEntry {
  final String name;
  final String email;
  final int totalPoints;

  LeaderboardEntry({
    required this.name,
    required this.email,
    required this.totalPoints,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      totalPoints: (json['total_points'] ?? 0) is int
          ? json['total_points']
          : int.tryParse(json['total_points'].toString()) ?? 0,
    );
  }
}
