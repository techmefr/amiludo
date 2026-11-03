class ManagedUser {
  const ManagedUser({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    this.admin = false,
    this.confirmed = false,
    this.blocked = false,
    this.lastSignInAt,
  });

  factory ManagedUser.fromJson(Map<String, dynamic> json) => ManagedUser(
    id: json['id'] as String,
    email: json['email'] as String? ?? '',
    name: json['name'] as String? ?? '',
    admin: json['admin'] == true,
    confirmed: json['confirmed'] == true,
    blocked: json['blocked'] == true,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastSignInAt: switch (json['lastSignInAt']) {
      final String at => DateTime.parse(at),
      _ => null,
    },
  );

  final String id, email, name;
  final bool admin, confirmed, blocked;
  final DateTime createdAt;
  final DateTime? lastSignInAt;

  String get label => name.isEmpty ? email : name;
}

enum AdminError implements Exception {
  forbidden,
  invalidEmail,
  self,
  rejected,
  unavailable,
  unreachable,
}
