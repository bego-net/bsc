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
            content: Text(l10n.nameUpdated),
            behavior: SnackBarBehavior.floating,
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
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthState>().logOut();
            },
            child: Text(l10n.logOut),
          ),
        ],
      ),
    );
  }

  // ── Initials helper ──────────────────────────────────────────────────────────
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = context.watch<AuthState>();
    final localeState = context.watch<LocaleState>();
    final studyState = context.watch<StudyState>();
    final otState = context.watch<OtState>();
    final teamState = context.watch<TeamState>();
    final l10n = AppLocalizations.of(context)!;

    final user = authState.user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final initials = _initials(user.name);
    final joinDate = DateFormat.yMMMd(localeState.languageCode).format(user.createdAt);
    final ibsStreak = studyState.streak;
    final ibsReadingDays =
        studyState.history.where((e) => e.completed).length;
    final otStreak = otState.streak;
    final otReadingDays = otState.completedDaysCount;
    final isPrepared = teamState.isPrepared;
    final reminderTime = studyState.reminderTime.format(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // ── Avatar & basic info ──────────────────────────────────────────
              _buildCard(
                context,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isAdmin
                            ? colorScheme.tertiary.withValues(alpha: 0.15)
                            : colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: user.isAdmin
                              ? colorScheme.tertiary
                              : colorScheme.primary,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        user.isAdmin ? l10n.adminBadge : l10n.memberBadge,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: user.isAdmin
                              ? colorScheme.tertiary
                              : colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Username (read-only)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.alternate_email),
                      title: Text(
                        user.username.isEmpty ? '—' : user.username,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(l10n.usernameReadOnly),
                    ),
                    // Join date
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(joinDate),
                      subtitle: Text(l10n.memberSince),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Edit name ────────────────────────────────────────────────────
              _buildCard(
                context,
                title: l10n.displayName,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.fullName,
                        prefixIcon: const Icon(Icons.person_outline),
                        errorText: _nameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: _nameSaving ? null : () => _saveName(l10n),
                      child: _nameSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.saveName),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Stats ────────────────────────────────────────────────────────
              _buildCard(
                context,
                title: l10n.stats,
                child: Column(
                  children: [
                    _buildStatRow(
                        context, l10n.ibsStreakLabel, l10n.daysCount(ibsStreak), '🔥'),
                    _buildStatRow(
                        context, l10n.ibsReadingDaysLabel, '$ibsReadingDays', '📖'),
                    _buildStatRow(
                        context, l10n.otStreakLabel, l10n.daysCount(otStreak), '🕊️'),
                    _buildStatRow(
                        context, l10n.otReadingDaysLabel, '$otReadingDays', '📜'),
                    _buildStatRow(
                        context,
                        l10n.teamBsPreparedLabel,
                        isPrepared ? l10n.yesCheck : l10n.notYet,
                        '👥'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Settings ─────────────────────────────────────────────────────
              _buildCard(
                context,
                title: l10n.settings,
                child: Column(
                  children: [
                    // Language setting
                    ListTile(
                      leading: Icon(Icons.language, color: colorScheme.primary),
                      title: Text(l10n.language),
                      trailing: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'am',
                            label: Text('አማርኛ', style: TextStyle(fontSize: 12)),
                          ),
                          ButtonSegment(
                            value: 'en',
                            label: Text('English', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                        selected: {localeState.languageCode},
                        onSelectionChanged: (selected) {
                          localeState.setLanguage(
                            selected.first,
                            user: user,
                            authRepo: context.read<AuthRepository>(),
                            teamState: teamState,
                            otState: otState,
                          );
                        },
                        showSelectedIcon: false,
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    // Daily reminder time
                    ListTile(
                      leading: Icon(Icons.alarm, color: colorScheme.primary),
                      title: Text(l10n.dailyReminder),
                      subtitle: Text(reminderTime),
                      trailing: OutlinedButton.icon(
                        onPressed: () => _pickReminderTime(context),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(l10n.change),
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    // OT reminders switch
                    SwitchListTile(
                      secondary:
                          Icon(Icons.menu_book_outlined, color: colorScheme.primary),
                      title: Text(l10n.otReminders),
                      value: otState.remindersEnabled,
                      onChanged: (val) => otState.setRemindersEnabled(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ── Change password ──────────────────────────────────────────────
              _buildCard(
                context,
                title: l10n.changePasswordTitle,
                child: Form(
                  key: _changePasswordKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_pwSuccess)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Text(l10n.passwordUpdatedSuccess,
                              style: const TextStyle(color: Colors.green)),
                        ),
                      if (_pwError != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _pwError!,
                            style:
                                TextStyle(color: colorScheme.onErrorContainer),
                          ),
                        ),
                      _buildPasswordField(
                        controller: _currentPwController,
                        label: l10n.currentPassword,
                        obscure: _obscureCurrent,
                        toggle: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? l10n.error : null,
                      ),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                        controller: _newPwController,
                        label: l10n.newPasswordHint,
                        obscure: _obscureNew,
                        toggle: () =>
                            setState(() => _obscureNew = !_obscureNew),
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
                        toggle: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                        validator: (v) => v != _newPwController.text
                            ? l10n.passwordsDoNotMatch
                            : null,
                        action: TextInputAction.done,
                        onSubmit: (_) => _changePassword(l10n),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: _pwSaving ? null : () => _changePassword(l10n),
                        child: _pwSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Text(l10n.updatePassword),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Log out ──────────────────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: () => _logout(context, l10n),
                icon: const Icon(Icons.logout),
                label: Text(l10n.logOut),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _buildCard(BuildContext context,
      {required Widget child, String? title}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
            ],
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context, String label, String value, String emoji) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }
}
