class User {
  final int? id;
  final String username;
  final String password;
  final String role; // role (user/admin)

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  // Mengonversi objek User menjadi Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'password': password, 'role': role};
  }

  // Factory untuk membuat objek User dari Map (hasil query database)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?, // Pastikan id dapat bernilai null
      username: map['username'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
    );
  }
}
