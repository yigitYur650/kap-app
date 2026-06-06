import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'auth_service.dart';

/// Implementation of [AuthService] using Supabase.
class SupabaseAuthImpl implements AuthService {
  final _supabase = supabase.Supabase.instance.client;

  @override
  Stream<supabase.AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  @override
  supabase.User? get currentUser => _supabase.auth.currentUser;

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      ).timeout(const Duration(seconds: 15));
    } on supabase.AuthException catch (e, stackTrace) {
      _logException('signInWithEmail', e, stackTrace);
      
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') || msg.contains('invalid credentials') || msg.contains('email not confirmed')) {
        throw InvalidCredentialsException(originalError: e, stackTrace: stackTrace);
      } else if (msg.contains('network') || msg.contains('connection')) {
        throw NetworkException(originalError: e, stackTrace: stackTrace);
      }
      throw UnknownAuthException(e.message, originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      _logException('signInWithEmail (Unhandled)', e, stackTrace);
      if (e is TimeoutException) {
        throw NetworkException(originalError: e, stackTrace: stackTrace);
      }
      throw UnknownAuthException('Giriş yapılamadı. Lütfen daha sonra tekrar deneyin.', originalError: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      ).timeout(const Duration(seconds: 15));

      final user = response.user;
      if (user != null) {
        // Link the user to the family_members table using their auth UID.
        await _supabase.from('family_members').upsert({
          'id': user.id,
          'name': name.trim(),
        }).timeout(const Duration(seconds: 15));
      }
    } on supabase.AuthException catch (e, stackTrace) {
      _logException('signUpWithEmail', e, stackTrace);
      
      final msg = e.message.toLowerCase();
      if (msg.contains('user already exists') || msg.contains('already registered')) {
        throw EmailAlreadyInUseException(originalError: e, stackTrace: stackTrace);
      } else if (msg.contains('password should be') || msg.contains('weak password')) {
        throw WeakPasswordException(originalError: e, stackTrace: stackTrace);
      } else if (msg.contains('network') || msg.contains('connection')) {
        throw NetworkException(originalError: e, stackTrace: stackTrace);
      }
      throw UnknownAuthException(e.message, originalError: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      _logException('signUpWithEmail (Unhandled)', e, stackTrace);
      if (e is TimeoutException) {
        throw NetworkException(originalError: e, stackTrace: stackTrace);
      }
      throw UnknownAuthException('Kayıt olunamadı. Lütfen bilgilerinizi kontrol edip tekrar deneyin.', originalError: e, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut().timeout(const Duration(seconds: 15));
    } catch (e, stackTrace) {
      _logException('signOut', e, stackTrace);
      throw UnknownAuthException('Çıkış yapılamadı.', originalError: e, stackTrace: stackTrace);
    }
  }

  void _logException(String operation, dynamic error, StackTrace stackTrace) {
    debugPrint('[AuthService] Hata ($operation): $error');
    debugPrint('[AuthService] StackTrace:\n$stackTrace');
    // Centralized logging tools (like Sentry) would capture the exception here:
    // Sentry.captureException(error, stackTrace: stackTrace);
  }
}
