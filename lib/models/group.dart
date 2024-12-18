class Group {
  final String id;
  final String name;
  final String? avatarUrl;
  final String adminId;
  final List<String> memberIds;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.adminId,
    required this.memberIds,
    required this.createdAt,
  });
} 