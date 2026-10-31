import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Help screen shown when the user taps "Forgot password?".
/// Explains that the leader must reset the password and provides
/// a convenient "Copy request message" button.
class ForgotPasswordScreen extends StatefulWidget {
  /// Pre-fill the username field if the user already typed one on the login screen.
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
    _usernameController =
        TextEditingController(text: widget.initialUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _copyMessage() async {
    final username = _usernameController.text.trim();
    final message = username.isEmpty
        ? 'Please reset my Bible Study password.'
        : 'Please reset my Bible Study password. My username is $username.';
    await Clipboard.setData(ClipboardData(text: message));
    if (mounted) {
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 3),
          () => mounted ? setState(() => _copied = false) : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.help_outline,
                        size: 48, color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Need help?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Password resets are handled by your Bible Study leader. '
                      'Send them a message using the button below and they will '
                      'give you a temporary password.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Username field
                    TextField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Your username',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Copy button
                    OutlinedButton.icon(
                      onPressed: _copyMessage,
                      icon: Icon(
                          _copied ? Icons.check : Icons.copy_outlined,
                          size: 18),
                      label: Text(
                          _copied ? 'Copied!' : 'Copy request message'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The message will be: '
                      '"Please reset my Bible Study password. My username is <your username>."',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                        fontStyle: FontStyle.italic,
                      ),
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
