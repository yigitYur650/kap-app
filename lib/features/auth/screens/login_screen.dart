import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:kap/l10n/app_localizations.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  bool _isLogin = true;
  bool _isLoading = false;

  void _submit() async {
    if (_isLoading) return;
    if (_formKey.currentState!.saveAndValidate()) {
      setState(() {
        _isLoading = true;
      });

      final values = _formKey.currentState!.value;
      final String email = (values['email'] as String).trim();
      final String password = values['password'] as String;
      final String name = _isLogin ? '' : (values['name'] as String).trim();

      final authService = context.read<AuthService>();
      final l10n = AppLocalizations.of(context)!;

      try {
        if (_isLogin) {
          await authService.signInWithEmail(email: email, password: password);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.loginSuccess),
                backgroundColor: KapColors.slateDark,
              ),
            );
          }
        } else {
          await authService.signUpWithEmail(email: email, password: password, name: name);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.registerSuccess),
                backgroundColor: KapColors.slateDark,
              ),
            );
          }
        }
      } on AuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: KapColors.mutedRed,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isLogin ? l10n.loginError : l10n.registerError),
              backgroundColor: KapColors.mutedRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: KapColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Title
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: KapColors.primaryAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: KapColors.primaryAccent,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isLogin ? l10n.login : l10n.register,
                  style: const TextStyle(
                    color: KapColors.slateDark,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Alışveriş listenizi yönetmek için giriş yapın.'
                      : 'Yeni bir aile hesabı oluşturup paylaşmaya başlayın.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Card Wrapper
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: KapColors.pureWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: KapColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ShadForm(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_isLogin) ...[
                          ShadInputFormField(
                            id: 'name',
                            label: Text(
                              l10n.name,
                              style: const TextStyle(
                                color: KapColors.slateDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            placeholder: Text(
                              l10n.enterMemberName,
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                            validator: (v) {
                              if (v.trim().isEmpty) {
                                return l10n.nameRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        ShadInputFormField(
                          id: 'email',
                          label: Text(
                            l10n.email,
                            style: const TextStyle(
                              color: KapColors.slateDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          placeholder: Text(
                            'Örn: eposta@adres.com',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v.trim().isEmpty) {
                              return l10n.emailRequired;
                            }
                            final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegExp.hasMatch(v)) {
                              return l10n.invalidEmail;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ShadInputFormField(
                          id: 'password',
                          label: Text(
                            l10n.password,
                            style: const TextStyle(
                              color: KapColors.slateDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          placeholder: Text(
                            '••••••••',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          obscureText: true,
                          validator: (v) {
                            if (v.isEmpty) {
                              return l10n.passwordRequired;
                            }
                            if (v.length < 6) {
                              return l10n.passwordTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        ShadButton(
                          backgroundColor: KapColors.primaryAccent,
                          hoverBackgroundColor: KapColors.primaryAccent.withValues(alpha: 0.8),
                          onPressed: _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: KapColors.pureWhite,
                                  ),
                                )
                              : Text(
                                  _isLogin ? l10n.login : l10n.register,
                                  style: const TextStyle(
                                    color: KapColors.pureWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Toggle Button
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _formKey.currentState?.reset();
                    });
                  },
                  child: Text(
                    _isLogin ? l10n.dontHaveAccount : l10n.alreadyHaveAccount,
                    style: const TextStyle(
                      color: KapColors.primaryAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
