import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../ui/ui.dart';

/// Help screen shown when the user taps "Forgot password?".
class ForgotPasswordScreen extends StatefulWidget {
  final String initialUsername;

  const ForgotPasswordScreen({super.key, this.initialUsername = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _usernameController;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _copyMessage(BuildContext context) async {
    final username = _usernameController.text.trim();
    final isAm = Localizations.localeOf(context).languageCode == 'am';
    final message = isAm
        ? (username.isEmpty
            ? 'እባክዎ የመጽሐፍ ቅዱስ ጥናት የይለፍ ቃሌን ዳግም ያስጀምሩ።'
            : 'እባክዎ የመጽሐፍ ቅዱስ ጥናት የይለፍ ቃሌን ዳግም ያስጀምሩ። የተጠቃሚ ስሜ $username ነው።')
        : (username.isEmpty
            ? 'Please reset my Bible Study password.'
            : 'Please reset my Bible Study password. My username is $username.');
    await Clipboard.setData(ClipboardData(text: message));
    if (mounted) {
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 3),
          () => mounted ? setState(() => _copied = false) : null);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(l10n.forgotPassword, style: AppTextStyles.title()),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AppCard(
                padding: const EdgeInsets.all(28.0),
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
                          Icons.help_outline_rounded,
                          size: 32,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.needHelp,
                      style: AppTextStyles.headingLarge(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.forgotPasswordHelp,
                      style: AppTextStyles.body(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Username field
                    TextField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      style: AppTextStyles.body(),
                      decoration: InputDecoration(
                        labelText: l10n.yourUsername,
                        labelStyle: AppTextStyles.caption(),
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
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
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Copy button
                    PrimaryButton(
                      label: _copied ? l10n.copied : l10n.copyRequestMessage,
                      icon: _copied ? Icons.check_circle : Icons.copy_rounded,
                      isOutlined: !_copied,
                      onPressed: () => _copyMessage(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.requestMessagePreview,
                      style: AppTextStyles.caption(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
