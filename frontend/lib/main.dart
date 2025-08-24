import 'package:auth_app/core/theme/app_theme.dart';
import 'package:auth_app/shared/providers/router_provider.dart';
import 'package:auth_app/shared/providers/theme_provider.dart';
import 'package:auth_app/shared/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  // Initialize AuthService with SharedPreferences
  // overrides array is used to inject dependencies
  // so that we can easily mock them in tests
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const AuthApp(),
    ),
  );
}

class AuthApp extends ConsumerWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Auth app',

      // App theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Navigation
      routerConfig: router,
    );
  }
}
