import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../repositories/auth_repository.dart';
import '../state/auth_state.dart';
import '../state/locale_state.dart';
import '../state/ot_state.dart';
import '../state/study_state.dart';
import '../state/team_state.dart';
import '../ui/ui.dart';

/// User profile screen: edit name, view stats, settings, change password, log out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Name editing ────────────────────────────────────────────────────────────
  late final TextEditingController _nameController;
  bool _nameSaving = false;
  String? _nameError;

  // ── Change password ──────────────────────────────────────────────────────────
  final _changePasswordKey = GlobalKey<FormState>();
  final _currentPwController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _pwSaving = false;
  String? _pwError;
  bool _pwSuccess = false;

  @override
  void initState() {
    super.initState();
    final name = context.read<AuthState>().user?.name ?? '';
    _nameController = TextEditingController(text: name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  // ── Name save ────────────────────────────────────────────────────────────────
  Future<void> _saveName(AppLocalizations l10n) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l10n.nameCannotBeEmpty);
      return;
    }
    setState(() {
      _nameSaving = true;
      _nameError = null;
    });
    final authState = context.read<AuthState>();
    final ok = await authState.updateName(name);
    if (mounted) {
      setState(() {
        _nameSaving = false;
        _nameError = ok ? null : (authState.errorMessage ?? l10n.error);
      });
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.nameUpdated, style: AppTextStyles.body(color: Colors.white)),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ── Change password ──────────────────────────────────────────────────────────
  Future<void> _changePassword(AppLocalizations l10n) async {
    if (!_changePasswordKey.currentState!.validate()) return;
    setState(() {
      _pwSaving = true;
      _pwError = null;
      _pwSuccess = false;
    });
    final authState = context.read<AuthState>();
    final ok = await authState.changePassword(
      currentPassword: _currentPwController.text,
      newPassword: _newPwController.text,
    );
    if (mounted) {
      setState(() {
        _pwSaving = false;
        if (ok) {
          _pwSuccess = true;
          _currentPwController.clear();
          _newPwController.clear();
          _confirmPwController.clear();
        } else {
          _pwError = authState.errorMessage ?? l10n.error;
        }
      });
    }
  }

  // ── Reminder time picker ─────────────────────────────────────────────────────
  Future<void> _pickReminderTime(BuildContext context) async {
    final studyState = context.read<StudyState>();
    final selected = await showTimePicker(
      context: context,
      initialTime: studyState.reminderTime,
    );
    if (selected != null) {
      await studyState.setReminderTime(selected);
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────────
  void _logout(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.logoutConfirmTitle, style: AppTextStyles.title()),
        content: Text(l10n.logoutConfirmMessage, style: AppTextStyles.body()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: AppTextStyles.caption(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthState>().logOut();
            },
            child: Text(l10n.logOut, style: AppTextStyles.button()),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final localeState = context.watch<LocaleState>();
    final studyState = context.watch<StudyState>();
    final otState = context.watch<OtState>();
    final teamState = context.watch<TeamState>();
    final l10n = AppLocalizations.of(context)!;

    final user = authState.user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accent)));
    }

    final initials = _initials(user.name);
    final joinDate = DateFormat.yMMMd(localeState.languageCode).format(user.createdAt);
    final ibsStreak = studyState.streak;
    final ibsReadingDays = studyState.history.where((e) => e.completed).length;
    final otStreak = otState.streak;
    final otReadingDays = otState.completedDaysCount;
    final isPrepared = teamState.isPrepared;
    final reminderTime = studyState.reminderTime.format(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.profile, style: AppTextStyles.title()),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // ── Avatar & Basic Info Card ─────────────────────────────────
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: AppTextStyles.headingLarge(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      StatChip(
                        label: user.isAdmin ? l10n.adminBadge : l10n.memberBadge,
                        backgroundColor: user.isAdmin
                            ? AppColors.gold.withValues(alpha: 0.15)
                            : AppColors.accent.withValues(alpha: 0.12),
                        borderColor: user.isAdmin ? AppColors.gold : AppColors.accent,
                        textColor: user.isAdmin ? AppColors.gold : AppColors.accent,
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 10),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.alternate_email, color: AppColors.accent),
                        title: Text(
                          user.username.isEmpty ? '—' : user.username,
                          style: AppTextStyles.title(),
                        ),
                        subtitle: Text(l10n.usernameReadOnly, style: AppTextStyles.caption()),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_outlined, color: AppColors.accent),
                        title: Text(joinDate, style: AppTextStyles.title()),
                        subtitle: Text(l10n.memberSince, style: AppTextStyles.caption()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Edit Name Card ───────────────────────────────────────────
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionTitle(title: l10n.displayName, padding: EdgeInsets.zero),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.body(),
                        decoration: InputDecoration(
                          labelText: l10n.fullName,
                          labelStyle: AppTextStyles.caption(),
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
                          errorText: _nameError,
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
                      const SizedBox(height: 14),
                      PrimaryButton(
                        label: l10n.saveName,
                        isTonal: true,
                        height: 48,
                        isLoading: _nameSaving,
                        onPressed: () => _saveName(l10n),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Stats Card ───────────────────────────────────────────────
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(title: l10n.stats, padding: EdgeInsets.zero),
                      const SizedBox(height: 8),
                      _buildStatRow(l10n.ibsStreakLabel, l10n.daysCount(ibsStreak), '🔥'),
                      _buildStatRow(l10n.ibsReadingDaysLabel, '$ibsReadingDays', '📖'),
                      _buildStatRow(l10n.otStreakLabel, l10n.daysCount(otStreak), '🕊️'),
                      _buildStatRow(l10n.otReadingDaysLabel, '$otReadingDays', '📜'),
                      _buildStatRow(
                        l10n.teamBsPreparedLabel,
                        isPrepared ? l10n.yesCheck : l10n.notYet,
                        '👥',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Settings Card ────────────────────────────────────────────
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(title: l10n.settings, padding: EdgeInsets.zero),
                      const SizedBox(height: 12),
                      // Language switcher
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.language, color: AppColors.accent),
                        title: Text(l10n.language, style: AppTextStyles.body(fontWeight: FontWeight.w600)),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildLangChip(
                                'am',
                                'አማርኛ',
                                localeState.languageCode,
                                () => localeState.setLanguage(
                                  'am',
                                  user: user,
                                  authRepo: context.read<AuthRepository>(),
                                  teamState: teamState,
                                  otState: otState,
                                ),
                              ),
                              _buildLangChip(
                                'en',
                                'English',
                                localeState.languageCode,
                                () => localeState.setLanguage(
                                  'en',
                                  user: user,
                                  authRepo: context.read<AuthRepository>(),
                                  teamState: teamState,
                                  otState: otState,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(color: AppColors.border, height: 16),
                      // Daily reminder
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.alarm, color: AppColors.accent),
                        title: Text(l10n.dailyReminder, style: AppTextStyles.body(fontWeight: FontWeight.w600)),
                        subtitle: Text(reminderTime, style: AppTextStyles.caption()),
                        trailing: OutlinedButton.icon(
                          onPressed: () => _pickReminderTime(context),
                          icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.accent),
                          label: Text(l10n.change, style: AppTextStyles.caption(color: AppColors.accent)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const Divider(color: AppColors.border, height: 16),
                      // OT Reminders switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.accent,
                        secondary: const Icon(Icons.menu_book_outlined, color: AppColors.accent),
                        title: Text(l10n.otReminders, style: AppTextStyles.body(fontWeight: FontWeight.w600)),
                        value: otState.remindersEnabled,
                        onChanged: (val) => otState.setRemindersEnabled(val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Change Password Card ─────────────────────────────────────
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _changePasswordKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionTitle(title: l10n.changePasswordTitle, padding: EdgeInsets.zero),
                        const SizedBox(height: 12),
                        if (_pwSuccess)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.accent),
                            ),
                            child: Text(
                              l10n.passwordUpdatedSuccess,
                              style: AppTextStyles.body(color: AppColors.accent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (_pwError != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.error),
                            ),
                            child: Text(
                              _pwError!,
                              style: AppTextStyles.body(color: AppColors.error),
                            ),
                          ),
                        _buildPasswordField(
                          controller: _currentPwController,
                          label: l10n.currentPassword,
                          obscure: _obscureCurrent,
                          toggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                          validator: (v) => (v == null || v.isEmpty) ? l10n.error : null,
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordField(
                          controller: _newPwController,
                          label: l10n.newPasswordHint,
                          obscure: _obscureNew,
                          toggle: () => setState(() => _obscureNew = !_obscureNew),
                          validator: (v) {
                            if (v == null || v.length < 6) {
                              return l10n.passwordMinLength;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildPasswordField(
                          controller: _confirmPwController,
                          label: l10n.confirmNewPassword,
                          obscure: _obscureConfirm,
                          toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          validator: (v) => v != _newPwController.text ? l10n.passwordsDoNotMatch : null,
                          action: TextInputAction.done,
                          onSubmit: (_) => _changePassword(l10n),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: l10n.updatePassword,
                          isTonal: true,
                          height: 48,
                          isLoading: _pwSaving,
                          onPressed: () => _changePassword(l10n),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Log Out Button ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _logout(context, l10n),
                    icon: const Icon(Icons.logout, color: AppColors.error),
                    label: Text(
                      l10n.logOut,
                      style: AppTextStyles.button(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, String icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTextStyles.body())),
          Text(value, style: AppTextStyles.title(color: AppColors.accent)),
        ],
      ),
    );
  }

  Widget _buildLangChip(String code, String label, String current, VoidCallback onTap) {
    final isSelected = code == current;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    required FormFieldValidator<String> validator,
    TextInputAction action = TextInputAction.next,
    ValueChanged<String>? onSubmit,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action,
      onFieldSubmitted: onSubmit,
      style: AppTextStyles.body(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.caption(),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: toggle,
        ),
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
      validator: validator,
    );
  }
}
