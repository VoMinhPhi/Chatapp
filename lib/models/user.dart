class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool isTyping;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
    this.isTyping = false,
  });

  User copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastSeen,
    bool? isTyping,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      isTyping: isTyping ?? this.isTyping,
    );
  }
} 