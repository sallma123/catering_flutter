class LoginResponse {
  final int id;
  final String email;
  final String? password;

  LoginResponse({required this.id, required this.email, this.password});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json["id"],
      email: json["email"],
      password: json["password"],
    );
  }
}
