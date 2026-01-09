class User {
  final String username;
  final String? email;
  final int userId;

  User({
    required this.username,
    this.email,
    required this.userId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      email: json['email'] as String?,
      userId: json['userId'] as int,
    );
  }
}

