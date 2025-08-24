import 'package:auth_app/shared/providers/form_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../widgets/validated_text_field.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final formState = ref.watch(loginFormProvider);

    // Listen to auth state changes
    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // App logo/title
              Icon(
                Icons.people,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                'Sign in to continue sharing moments',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Email field with Riverpod validation
              ValidatedTextField(
                labelText: 'Email',
                hintText: 'Enter your email address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: !authState.isLoading,
                value: formState.email.value,
                errorText: formState.email.isDirty ? formState.email.error : null,
                onChanged: (value) {
                  ref.read(loginFormProvider.notifier).updateEmail(value);
                },
                onSubmitted: (_) => _handleLogin(context, ref),
              ),
              const SizedBox(height: 16),

              // Password field with Riverpod validation
              ValidatedPasswordField(
                labelText: 'Password',
                hintText: 'Enter your password',
                enabled: !authState.isLoading,
                value: formState.password.value,
                errorText: formState.password.isDirty ? formState.password.error : null,
                onChanged: (value) {
                  ref.read(loginFormProvider.notifier).updatePassword(value);
                },
                onSubmitted: (_) => _handleLogin(context, ref),
              ),
              const SizedBox(height: 24),

              // Login button
              // We cannot use const here because authState.isLoading is dynamic
              // and changes based on user interaction
              ElevatedButton(
                onPressed: authState.isLoading 
                    ? null 
                    : () => _handleLogin(context, ref),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Forgot password link
              TextButton(
                onPressed: authState.isLoading 
                    ? null 
                    : () {
                        // TODO: Implement forgot password
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Forgot password - Coming Soon'),
                          ),
                        );
                      },
                child: const Text('Forgot Password?'),
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            // Reset form when navigating away
                            ref.read(loginFormProvider.notifier).reset();
                            context.go('/signup');
                          },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, WidgetRef ref) async {
    // Validate all fields first
    ref.read(loginFormProvider.notifier).validateAllFields();
    
    final formState = ref.read(loginFormProvider);
    
    if (!formState.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fix the errors in the form'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    debugPrint('📧 LOGIN: Email: ${formState.email.value}');

    final success = await ref
        .read(authProvider.notifier)
        .signInWithEmail(
          email: formState.email.value.trim(),
          password: formState.password.value,
        );

    if (success) {
      debugPrint('✅ LOGIN: Success detected, navigating to feed');
      if (context.mounted) {
        // Reset form on successful login
        ref.read(loginFormProvider.notifier).reset();
        context.go('/feed');
      }
    } else {
      debugPrint('❌ LOGIN: Login failed, staying on login page');
    }
  }
}
