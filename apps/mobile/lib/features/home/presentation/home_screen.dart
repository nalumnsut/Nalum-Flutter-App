import 'package:flutter/material.dart';
import 'package:nalum_app/l10n/l10n.dart';
import 'package:nalum_ui/nalum_ui.dart';

/// Overview tab: welcome, quick actions, recent posts, suggestions, upcoming
/// events (docs/PLAN.md §1.2). Rendered inside the tab shell, which owns the
/// app bar. Built in M2.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => EmptyState(
    title: context.l10n.navHome,
    message: context.l10n.comingSoon,
    icon: Icons.home_outlined,
  );
}
