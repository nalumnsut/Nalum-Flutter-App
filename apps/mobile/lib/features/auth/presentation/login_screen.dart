import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nalum_app/core/network/app_failure.dart';
import 'package:nalum_app/core/ui/failure_text.dart';
import 'package:nalum_app/features/auth/application/auth_controller.dart';
import 'package:nalum_app/l10n/l10n.dart';
import 'package:nalum_ui/nalum_ui.dart';

/// Email + password sign-in. Google and Apple buttons arrive in M1
/// (docs/AUTH.md §4). Navigation after success is done by the router guard,
/// not here.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({required this.onCreateAccount, super.key});

  final VoidCallback onCreateAccount;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final failure = await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _email.text.trim(), password: _password.text);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (failure != null) {
      final l10n = context.l10n;
      // A 401 on sign-in means wrong credentials, not an expired session.
      final text = failure is UnauthorizedFailure
          ? l10n.errorInvalidCredentials
          : failureText(l10n, failure);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    String? required(String? value) =>
        (value == null || value.trim().isEmpty) ? l10n.fieldRequired : null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(NalumSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.signInTitle,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: NalumSpacing.xs),
                    Text(
                      l10n.signInSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: NalumSpacing.lg),
                    TextFormField(
                      controller: _email,
                      decoration: InputDecoration(labelText: l10n.emailLabel),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: required,
                    ),
                    const SizedBox(height: NalumSpacing.md),
                    TextFormField(
                      controller: _password,
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel,
                      ),
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      validator: required,
                    ),
                    const SizedBox(height: NalumSpacing.lg),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.signInButton),
                    ),
                    const SizedBox(height: NalumSpacing.sm),
                    TextButton(
                      onPressed: widget.onCreateAccount,
                      child: Text(l10n.createAccount),
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
