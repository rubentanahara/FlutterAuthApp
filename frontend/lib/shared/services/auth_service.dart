import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/auth_models.dart';

part 'auth_service.g.dart';

// Is this singleton?
// Yes, by using Riverpod's provider system, the Dio instance and SharedPreferences instance are effectively singletons within the scope of the application. This means that whenever you access these providers,
// you will get the same instance throughout the app's lifecycle.
@riverpod
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptors for logging and error handling
  dio.interceptors.add(
    LogInterceptor(requestBody: true, responseBody: true, error: true),
  );

  return dio;
}

@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  // Provider Scope in main.dart ensures initialization
  // so this should never be called before initialization
  throw UnimplementedError('SharedPreferences must be initialized');
}

@riverpod
class AuthService extends _$AuthService {
  @override
  void build() {}

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        AppConstants.loginEndpoint,
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      if (loginResponse.success && loginResponse.result != null) {
        // Store the token
        final prefs = ref.read(sharedPreferencesProvider);
        await prefs.setString(
          AppConstants.accessTokenKey,
          loginResponse.result!,
        );
      }

      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const LoginResponse(success: false, result: null);
      }
      rethrow;
    }
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        AppConstants.registerEndpoint,
        data: request.toJson(),
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        return RegisterResponse(
          success: false,
          message: errorData?['message'] ?? 'Registration failed',
        );
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.userDataKey);
  }

  Future<String?> getStoredToken() async {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getString(AppConstants.accessTokenKey);
  }

  Future<void> storeUserData(User user) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.userDataKey, user.toJson().toString());
  }
}
