import 'dart:developer';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/auth_models.dart';
import '../services/auth_service.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    // Initialize the state first
    final initialState = const AuthState(isLoading: true);
    
    // Then perform async initialization
    _init();
    
    return initialState;
  }

  Future<void> _init() async {
    try {
      final authService = ref.read(authServiceProvider.notifier);
      final token = await authService.getStoredToken();
      
      if (token != null && !JwtDecoder.isExpired(token)) {
        // Token is valid, extract user info from JWT
        final decodedToken = JwtDecoder.decode(token);
        final user = User(
          id: decodedToken['sub'] ?? '',
          name: decodedToken['Name'] ?? '',
          email: decodedToken['email'] ?? '',
          userName: decodedToken['email'] ?? '',
        );
        
        state = const AuthState().copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
          token: token,
          error: null,
        );
      } else {
        // Token is null or expired
        if (token != null) {
          await authService.logout(); // Clear expired token
        }
        state = const AuthState().copyWith(
          isAuthenticated: false,
          isLoading: false,
          user: null,
          token: null,
          error: null,
        );
      }
    } catch (e) {
      log('Error initializing auth: $e');
      state = const AuthState().copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: 'Failed to initialize authentication',
      );
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final authService = ref.read(authServiceProvider.notifier);
      final loginRequest = LoginRequest(email: email, password: password);
      final response = await authService.login(loginRequest);
      
      if (response.success && response.result != null) {
        // Decode the JWT token to get user information
        final decodedToken = JwtDecoder.decode(response.result!);
        final user = User(
          id: decodedToken['sub'] ?? '',
          name: decodedToken['Name'] ?? '',
          email: decodedToken['email'] ?? '',
          userName: decodedToken['email'] ?? '',
        );
        
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: user,
          token: response.result,
          error: null,
        );
        
        log('✅ AUTH: Sign in successful for ${user.email}');
        return true;
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          error: 'Invalid email or password',
        );
        log('❌ AUTH: Sign in failed - Invalid credentials');
        return false;
      }
    } catch (e) {
      log('❌ AUTH: Sign in error: $e');
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: 'Sign in failed. Please try again.',
      );
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final authService = ref.read(authServiceProvider.notifier);
      final registerRequest = RegisterRequest(
        name: name,
        email: email,
        password: password,
      );
      final response = await authService.register(registerRequest);
      
      if (response.success) {
        // Registration successful, now sign in
        final signInSuccess = await signInWithEmail(
          email: email,
          password: password,
        );
        
        if (signInSuccess) {
          log('✅ AUTH: Sign up and sign in successful for $email');
          return true;
        } else {
          state = state.copyWith(
            isLoading: false,
            error: 'Account created but sign in failed. Please try signing in manually.',
          );
          return false;
        }
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          error: response.message ?? 'Registration failed',
        );
        log('❌ AUTH: Sign up failed - ${response.message}');
        return false;
      }
    } catch (e) {
      log('❌ AUTH: Sign up error: $e');
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: 'Sign up failed. Please try again.',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      final authService = ref.read(authServiceProvider.notifier);
      await authService.logout();
      
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        user: null,
        token: null,
        error: null,
      );
      
      log('✅ AUTH: Sign out successful');
    } catch (e) {
      log('❌ AUTH: Sign out error: $e');
      // Even if there's an error, clear the state
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        user: null,
        token: null,
        error: null,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}