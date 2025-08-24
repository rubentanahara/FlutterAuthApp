// Login Request Model
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    email: json['email'] as String,
    password: json['password'] as String,
  );
}

// Register Request Model
class RegisterRequest {
  final String name;
  final String email;
  final String password;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
  };

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => RegisterRequest(
    name: json['name'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
  );
}

// Login Response Model
class LoginResponse {
  final bool success;
  final String? result;

  const LoginResponse({
    required this.success,
    this.result,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    success: json['success'] as bool,
    result: json['result'] as String?,
  );
}

// Register Response Model
class RegisterResponse {
  final bool success;
  final String? userName;
  final String? email;
  final String? name;
  final String? message;

  const RegisterResponse({
    required this.success,
    this.userName,
    this.email,
    this.name,
    this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
    success: json['success'] as bool,
    userName: json['userName'] as String?,
    email: json['email'] as String?,
    name: json['name'] as String?,
    message: json['message'] as String?,
  );
}

// User Model
class User {
  final String id;
  final String name;
  final String email;
  final String? userName;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.userName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'userName': userName,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    userName: json['userName'] as String?,
  );
}

// Auth State Model
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final User? user;
  final String? token;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.token,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    User? user,
    String? token,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      token: token ?? this.token,
      error: error,
    );
  }
}