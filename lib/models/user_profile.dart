class UserProfile{
  final String username;
  final String role;
  final int id;

  UserProfile({
    required this.username,
    required this.role,
    required this.id,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? "",
      role: json['role'] ?? "unknown",
      id: json['id'] ?? 0,
    );
  }
}