import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'form_validation_provider.g.dart';

// Form Field State Model
class FormFieldState {
  final String value;
  final String? error;
  final bool isValid;
  final bool isDirty; // Has been touched/modified

  const FormFieldState({
    this.value = '',
    this.error,
    this.isValid = true,
    this.isDirty = false,
  });

  FormFieldState copyWith({
    String? value,
    String? error,
    bool? isValid,
    bool? isDirty,
  }) {
    return FormFieldState(
      value: value ?? this.value,
      error: error,
      isValid: isValid ?? this.isValid,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

// Login Form State
class LoginFormState {
  final FormFieldState email;
  final FormFieldState password;
  final bool isValid;

  const LoginFormState({
    this.email = const FormFieldState(),
    this.password = const FormFieldState(),
    this.isValid = false,
  });

  LoginFormState copyWith({
    FormFieldState? email,
    FormFieldState? password,
    bool? isValid,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
    );
  }
}

// Signup Form State
class SignupFormState {
  final FormFieldState name;
  final FormFieldState username;
  final FormFieldState email;
  final FormFieldState password;
  final FormFieldState confirmPassword;
  final bool isValid;

  const SignupFormState({
    this.name = const FormFieldState(),
    this.username = const FormFieldState(),
    this.email = const FormFieldState(),
    this.password = const FormFieldState(),
    this.confirmPassword = const FormFieldState(),
    this.isValid = false,
  });

  SignupFormState copyWith({
    FormFieldState? name,
    FormFieldState? username,
    FormFieldState? email,
    FormFieldState? password,
    FormFieldState? confirmPassword,
    bool? isValid,
  }) {
    return SignupFormState(
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isValid: isValid ?? this.isValid,
    );
  }
}

// Validation Rules
class ValidationRules {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }

    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    if (value.length > 30) {
      return 'Username must be less than 30 characters';
    }

    final usernameRegex = RegExp(r'^[a-zA-Z0-9._]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, dots, and underscores';
    }

    if (value.startsWith('.') ||
        value.startsWith('_') ||
        value.endsWith('.') ||
        value.endsWith('_')) {
      return 'Username cannot start or end with dots or underscores';
    }

    return null;
  }
}

// Login Form Provider
@riverpod
class LoginForm extends _$LoginForm {
  @override
  LoginFormState build() {
    return const LoginFormState();
  }

  void updateEmail(String value) {
    final error = ValidationRules.validateEmail(value);
    final emailField = FormFieldState(
      value: value,
      error: error,
      isValid: error == null,
      isDirty: true,
    );

    state = state.copyWith(
      email: emailField,
      isValid: error == null && state.password.isValid,
    );
  }

  void updatePassword(String value) {
    final error = ValidationRules.validatePassword(value);
    final passwordField = FormFieldState(
      value: value,
      error: error,
      isValid: error == null,
      isDirty: true,
    );

    state = state.copyWith(
      password: passwordField,
      isValid: state.email.isValid && error == null,
    );
  }

  void validateAllFields() {
    final emailError = ValidationRules.validateEmail(state.email.value);
    final passwordError = ValidationRules.validatePassword(state.password.value);

    state = state.copyWith(
      email: state.email.copyWith(
        error: emailError,
        isValid: emailError == null,
        isDirty: true,
      ),
      password: state.password.copyWith(
        error: passwordError,
        isValid: passwordError == null,
        isDirty: true,
      ),
      isValid: emailError == null && passwordError == null,
    );
  }

  void reset() {
    state = const LoginFormState();
  }
}

// Signup Form Provider
@riverpod
class SignupForm extends _$SignupForm {
  @override
  SignupFormState build() {
    return const SignupFormState();
  }

  void updateName(String value) {
    final error = ValidationRules.validateName(value);
    final nameField = FormFieldState(
      value: value,
      error: error,
      isValid: error == null,
      isDirty: true,
    );

    state = state.copyWith(
      name: nameField,
      isValid: _isFormValid(),
    );
  }

  void updateUsername(String value) {
    final error = ValidationRules.validateUsername(value);
    final usernameField = FormFieldState(
      value: value,
      error: error,
      isValid: error == null,
      isDirty: true,
    );

    state = state.copyWith(
      username: usernameField,
      isValid: _isFormValid(),
    );
  }

  void updateEmail(String value) {
    final error = ValidationRules.validateEmail(value);
    final emailField = FormFieldState(
      value: value,
      error: error,
      isValid: error == null,
      isDirty: true,
    );

    state = state.copyWith(
      email: emailField,
      isValid: _isFormValid(),
    );
  }

  void updatePassword(String value) {
    final error = ValidationRules.validateStrongPassword(value);
    final passwordField = FormFieldState(
      value: value,
      error: error,
      isValid: error == null,
      isDirty: true,
    );

    // Also re-validate confirm password if it exists
    String? confirmPasswordError;
    if (state.confirmPassword.value.isNotEmpty) {
      confirmPasswordError = ValidationRules.validateConfirmPassword(
        state.confirmPassword.value,
        value,
      );
    }

    state = state.copyWith(
      password: passwordField,
      confirmPassword: state.confirmPassword.copyWith(
        error: confirmPasswordError,
        isValid: confirmPasswordError == null,
      ),
      isValid: _isFormValid(),
    );
  }

  void updateConfirmPassword(String value) {
    final error = ValidationRules.validateConfirmPassword(value, state.password.value);
    final confirmPasswordField = FormFieldState(
      value: value,
      error: error,
      isValid: error == null,
      isDirty: true,
    );

    state = state.copyWith(
      confirmPassword: confirmPasswordField,
      isValid: _isFormValid(),
    );
  }

  bool _isFormValid() {
    return state.name.isValid &&
        state.username.isValid &&
        state.email.isValid &&
        state.password.isValid &&
        state.confirmPassword.isValid &&
        state.name.value.isNotEmpty &&
        state.username.value.isNotEmpty &&
        state.email.value.isNotEmpty &&
        state.password.value.isNotEmpty &&
        state.confirmPassword.value.isNotEmpty;
  }

  void validateAllFields() {
    final nameError = ValidationRules.validateName(state.name.value);
    final usernameError = ValidationRules.validateUsername(state.username.value);
    final emailError = ValidationRules.validateEmail(state.email.value);
    final passwordError = ValidationRules.validateStrongPassword(state.password.value);
    final confirmPasswordError = ValidationRules.validateConfirmPassword(
      state.confirmPassword.value,
      state.password.value,
    );

    state = state.copyWith(
      name: state.name.copyWith(
        error: nameError,
        isValid: nameError == null,
        isDirty: true,
      ),
      username: state.username.copyWith(
        error: usernameError,
        isValid: usernameError == null,
        isDirty: true,
      ),
      email: state.email.copyWith(
        error: emailError,
        isValid: emailError == null,
        isDirty: true,
      ),
      password: state.password.copyWith(
        error: passwordError,
        isValid: passwordError == null,
        isDirty: true,
      ),
      confirmPassword: state.confirmPassword.copyWith(
        error: confirmPasswordError,
        isValid: confirmPasswordError == null,
        isDirty: true,
      ),
      isValid: nameError == null &&
          usernameError == null &&
          emailError == null &&
          passwordError == null &&
          confirmPasswordError == null,
    );
  }

  void reset() {
    state = const SignupFormState();
  }
}
