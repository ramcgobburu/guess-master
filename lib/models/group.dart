class Group {
  final String id;
  final String name;
  final String code;
  final String? createdBy;
  final DateTime createdAt;
  final bool isActive;

  Group({
    required this.id,
    required this.name,
    required this.code,
    this.createdBy,
    required this.createdAt,
    this.isActive = true,
  });

  factory Group.fromSupabase(Map<String, dynamic> json) {
    return Group(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }
}

class GroupStats {
  final String groupId;
  final String groupName;
  final String groupCode;
  final int memberCount;
  final int predictionCount;

  GroupStats({
    required this.groupId,
    required this.groupName,
    required this.groupCode,
    required this.memberCount,
    required this.predictionCount,
  });

  factory GroupStats.fromJson(Map<String, dynamic> json) {
    return GroupStats(
      groupId: json['group_id'] ?? '',
      groupName: json['group_name'] ?? '',
      groupCode: json['group_code'] ?? '',
      memberCount: json['member_count'] ?? 0,
      predictionCount: json['prediction_count'] ?? 0,
    );
  }
}
