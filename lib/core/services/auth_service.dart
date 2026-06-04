import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Abstract base class for all application exceptions.
abstract class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException(this.message, {this.originalError, this.stackTrace});

  @override
  String toString() => message;
}

/// Authentication related exceptions.
class AuthException extends AppException {
  AuthException(super.message, {super.originalError, super.stackTrace});
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException({dynamic originalError, StackTrace? stackTrace})
      : super(
          'Geçersiz e-posta veya şifre.',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException({dynamic originalError, StackTrace? stackTrace})
      : super(
          'Bu e-posta adresi zaten kullanımda.',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class WeakPasswordException extends AuthException {
  WeakPasswordException({dynamic originalError, StackTrace? stackTrace})
      : super(
          'Şifre çok zayıf. En az 6 karakter olmalıdır.',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class NetworkException extends AuthException {
  NetworkException({dynamic originalError, StackTrace? stackTrace})
      : super(
          'Bağlantı hatası. İnternet bağlantınızı kontrol edin.',
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

class UnknownAuthException extends AuthException {
  UnknownAuthException(super.message, {super.originalError, super.stackTrace});
}

/// Abstract contract for authentication service following Service Pattern.
abstract class AuthService {
  /// Stream to listen to real-time authentication state changes.
  Stream<supabase.AuthState> get onAuthStateChange;

  /// Gets the currently authenticated user, or null if unauthenticated.
  supabase.User? get currentUser;

  /// Signs in a user using email and password.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  /// Signs up a new user using email, password and display name.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  /// Signs out the currently authenticated user.
  Future<void> signOut();
}
