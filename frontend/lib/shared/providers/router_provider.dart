
import 'package:auth_app/features/authentication/presentation/pages/login_page.dart';
import 'package:auth_app/features/authentication/presentation/pages/signup_page.dart';
import 'package:auth_app/shared/widgets/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../providers/auth_provider.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/feed' : '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthPage = state.uri.path == '/login' || state.uri.path == '/signup';
      
      // If not authenticated and not on auth page, redirect to login
      if (!isAuthenticated && !isAuthPage) {
        return '/login';
      }
      
      // If authenticated and on auth page, redirect to feed
      if (isAuthenticated && isAuthPage) {
        return '/feed';
      }
      
      return null;
    },
    routes: [
      // Authentication routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      
      // Main app routes with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          GoRoute(
            path: '/feed',
            builder: (context, state) => const FeedPage(),
          ),
          GoRoute(
            path: '/create',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Text('Create Page - Coming Soon'),
              ),
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      
    ],
  );
});

