import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/auth_state.dart';
import '../ui/ui.dart';
import '../utils/auth_utils.dart';

/// Screen for new users to register an account with name, username, and password.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthState>();
    final success = await authState.signUp(
      name: _nameController.text,
      username: _usernameController.text.trim().toLowerCase(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      final rawError = authState.errorMessage ?? l10n.error;
      final isOffline = rawError.contains('network') ||
          rawError.contains('unavailable') ||
          rawError.contains('Failed host') ||
          rawError.contains('SocketException') ||
          rawError.contains('TimeoutException');
      final error = isOffline ? l10n.offlineSignupNotice : rawError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: AppTextStyles.body(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.createAccount,
          style: AppTextStyles.title(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AppCard(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_add_outlined,
                            size: 32,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.joinBibleStudy,
                        style: AppTextStyles.headingLarge(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.signupSubtitle,
                        style: AppTextStyles.subtitle(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.body(),
                        decoration: _inputDecoration(
                          labelText: l10n.fullName,
                          icon: Icons.badge_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.enterName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Username field
                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        style: AppTextStyles.body(),
                        decoration: _inputDecoration(
                          labelText: l10n.usernameHint,
                          icon: Icons.alternate_email,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.chooseUsername;
                          }
                          final normalized = value.trim().toLowerCase();
                          if (!isValidUsername(normalized)) {
                            return l10n.invalidUsername;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        style: AppTextStyles.body(),
                        decoration: _inputDecoration(
                          labelText: l10n.passwordHint,
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return l10n.passwordMinLength;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm password field
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(l10n),
                        style: AppTextStyles.body(),
                        decoration: _inputDecoration(
                          labelText: l10n.confirmPassword,
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return l10n.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      PrimaryButton(
                        label: l10n.signUp,
                        isLoading: authState.isLoading,
                        onPressed: () => _submit(l10n),
                      ),
                      const SizedBox(height: 20),

                      // Back to login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              l10n.alreadyHaveAccount,
                              style: AppTextStyles.body(color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              l10n.logIn,
                              style: AppTextStyles.body(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: AppTextStyles.caption(),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.8),
      ),
    );
  }
}
