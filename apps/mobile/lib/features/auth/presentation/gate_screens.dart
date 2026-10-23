import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nalum_app/features/auth/application/auth_controller.dart';
import 'package:nalum_app/l10n/l10n.dart';
import 'package:nalum_ui/nalum_ui.dart';

/// Screens for the auth-owned gates (docs/AUTH.md §5). Every gate screen
/// offers sign-out: a user stuck at a gate must never be trapped.
class GateScaffold extends ConsumerWidget {
  const GateScaffold({
    required this.title,
    required this.body,
    super.key,
    this.icon = Icons.lock_outline,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            child: Text(context.l10n.signOut),
          ),
        ],
      ),
      body: EmptyState(title: title, message: body, icon: icon),
    );
  }
}

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) => GateScaffold(
    title: context.l10n.verifyEmailTitle,
    body: context.l10n.verifyEmailBody,
    icon: Icons.mark_email_unread_outlined,
  );
}

class BannedScreen extends StatelessWidget {
  const BannedScreen({super.key});

  @override
  Widget build(BuildContext context) => GateScaffold(
    title: context.l10n.bannedTitle,
    body: context.l10n.bannedBody,
    icon: Icons.block,
  );
}

class AdminWebScreen extends StatelessWidget {
  const AdminWebScreen({super.key});

  @override
  Widget build(BuildContext context) => GateScaffold(
    title: context.l10n.adminWebTitle,
    body: context.l10n.adminWebBody,
    icon: Icons.admin_panel_settings_outlined,
  );
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.signUpTitle)),
    body: EmptyState(
      title: context.l10n.signUpTitle,
      message: context.l10n.comingSoon,
    ),
  );
}
