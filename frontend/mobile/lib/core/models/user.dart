class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.createdAt,
    this.displayName,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] as String,
        email: j['email'] as String,
        displayName: j['display_name'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'created_at': createdAt.toIso8601String(),
      };
}
