import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nalum_app/features/auth/application/auth_controller.dart';
import 'package:nalum_app/l10n/l10n.dart';
import 'package:nalum_ui/nalum_ui.dart';

/// Alumni verification: code, registry match, or admin review
/// (docs/PLAN.md §1.2, docs/AUTH.md §6). Built in M1.
class VerifyAlumniScreen extends ConsumerWidget {
  const VerifyAlumniScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyAlumniTitle),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            child: Text(l10n.signOut),
          ),
        ],
      ),
      body: EmptyState(
        title: l10n.verifyAlumniTitle,
        message: l10n.comingSoon,
        icon: Icons.verified_outlined,
      ),
    );
  }
}
