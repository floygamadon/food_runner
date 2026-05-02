class AppUser {
  final String uid;
  final String email;
  final String role;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'createdAt': DateTime.now(),
    };
  }
}