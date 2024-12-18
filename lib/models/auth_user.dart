class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? token;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      token: json['token'],
    );
  }
} 