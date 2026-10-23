import 'package:flutter/material.dart';
import 'package:nalum_app/l10n/l10n.dart';
import 'package:nalum_ui/nalum_ui.dart';

/// In-app notification list (docs/NOTIFICATIONS.md §4). Built in M2.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.notificationsTitle)),
    body: EmptyState(
      title: context.l10n.notificationsTitle,
      message: context.l10n.comingSoon,
      icon: Icons.notifications_none,
    ),
  );
}
