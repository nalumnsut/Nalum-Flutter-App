import 'package:flutter/material.dart';
import 'package:nalum_app/l10n/l10n.dart';
import 'package:nalum_ui/nalum_ui.dart';

/// Events tab: upcoming events, filters, my events (docs/PLAN.md §1.2).
/// Built in M2/M4.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) => EmptyState(
    title: context.l10n.navEvents,
    message: context.l10n.comingSoon,
    icon: Icons.event_outlined,
  );
}
