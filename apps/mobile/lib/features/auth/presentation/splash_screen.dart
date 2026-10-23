import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nalum_app/features/auth/application/auth_controller.dart';
import 'package:nalum_app/features/auth/domain/auth_status.dart';
import 'package:nalum_app/l10n/l10n.dart';
import 'package:nalum_ui/nalum_ui.dart';

/// Shown while the stored session is checked, and when that check fails.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authControllerProvider);
    return Scaffold(
      body: switch (status) {
        AuthRestoreFailed() => ErrorState(
          message: context.l10n.restoreFailed,
          retryLabel: context.l10n.retry,
          onRetry: () => ref.read(authControllerProvider.notifier).restore(),
        ),
        AuthUnknown() ||
        AuthSignedOut() ||
        AuthSignedIn() => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
