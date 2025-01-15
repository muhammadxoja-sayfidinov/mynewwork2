// lib/models/user_model.dart
class UserModel {
  String id;
  String login;
  String password;
  String role; // 'admin' yoki 'texnik'

  UserModel({
    required this.id,
    required this.login,
    required this.password,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      login: json['login'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'texnik',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'password': password,
      'role': role,
    };
  }
}
