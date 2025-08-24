import 'package:auth_app/shared/providers/form_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/providers/auth_provider.dart';
import '../widgets/validated_text_field.dart';

class SignupPage extends ConsumerWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final formState = ref.watch(signupFormProvider);

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
                'Create Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                'Join the community and start sharing',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Name field
              ValidatedTextField(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                textCapitalization: TextCapitalization.words,
                enabled: !authState.isLoading,
                value: formState.name.value,
                errorText: formState.name.isDirty ? formState.name.error : null,
                onChanged: (value) {
                  ref.read(signupFormProvider.notifier).updateName(value);
                },
              ),
              const SizedBox(height: 16),

              // Username field
              ValidatedTextField(
                labelText: 'Username',
                hintText: 'Choose a unique username',
                helperText: 'This will be your unique identifier',
                prefixIcon: Icons.alternate_email,
                enabled: !authState.isLoading,
                value: formState.username.value,
                errorText: formState.username.isDirty ? formState.username.error : null,
                onChanged: (value) {
                  ref.read(signupFormProvider.notifier).updateUsername(value);
                },
              ),
              const SizedBox(height: 16),

              // Email field
              ValidatedTextField(
                labelText: 'Email',
                hintText: 'Enter your email address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: !authState.isLoading,
                value: formState.email.value,
                errorText: formState.email.isDirty ? formState.email.error : null,
                onChanged: (value) {
                  ref.read(signupFormProvider.notifier).updateEmail(value);
                },
              ),
              const SizedBox(height: 16),

              // Password field
              ValidatedPasswordField(
                labelText: 'Password',
                hintText: 'Create a strong password',
                helperText: 'At least 8 characters with uppercase, lowercase, and number',
                enabled: !authState.isLoading,
                value: formState.password.value,
                errorText: formState.password.isDirty ? formState.password.error : null,
                onChanged: (value) {
                  ref.read(signupFormProvider.notifier).updatePassword(value);
                },
              ),
              const SizedBox(height: 16),

              // Confirm password field
              ValidatedPasswordField(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                enabled: !authState.isLoading,
                value: formState.confirmPassword.value,
                errorText: formState.confirmPassword.isDirty ? formState.confirmPassword.error : null,
                onChanged: (value) {
                  ref.read(signupFormProvider.notifier).updateConfirmPassword(value);
                },
                onSubmitted: (_) => _handleSignup(context, ref),
              ),
              const SizedBox(height: 24),

              // Terms and conditions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Create account button
              ElevatedButton(
                onPressed: authState.isLoading 
                    ? null 
                    : () => _handleSignup(context, ref),
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
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            // Reset form when navigating away
                            ref.read(signupFormProvider.notifier).reset();
                            context.go('/login');
                          },
                    child: const Text(
                      'Sign In',
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

  void _handleSignup(BuildContext context, WidgetRef ref) async {
    // Validate all fields first
    ref.read(signupFormProvider.notifier).validateAllFields();
    
    final formState = ref.read(signupFormProvider);
    
    if (!formState.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fix the errors in the form'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    debugPrint('📧 SIGNUP: Email: ${formState.email.value}');

    final success = await ref
        .read(authProvider.notifier)
        .signUpWithEmail(
          name: formState.name.value.trim(),
          email: formState.email.value.trim(),
          password: formState.password.value,
        );

    if (success) {
      debugPrint('✅ SIGNUP: Success detected, proceeding to feed');

      if (context.mounted) {
        // Reset form on successful signup
        ref.read(signupFormProvider.notifier).reset();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome to Social, ${formState.name.value}!',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        context.go('/feed');
      }
    } else {
      debugPrint('❌ SIGNUP: Signup failed, staying on signup page');
    }
  }
}
