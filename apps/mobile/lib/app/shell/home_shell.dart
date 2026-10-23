import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nalum_app/app/router/app_routes.dart';
import 'package:nalum_app/l10n/l10n.dart';

/// Bottom-navigation scaffold for the five tabs (docs/NAVIGATION.md §1).
/// Each tab keeps its own stack; the shell owns the app bar so tab screens
/// stay plain widgets.
class HomeShell extends StatelessWidget {
  const HomeShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [
      (l10n.navHome, Icons.home_outlined, Icons.home),
      (l10n.navNetwork, Icons.people_outline, Icons.people),
      (l10n.navPosts, Icons.article_outlined, Icons.article),
      (l10n.navEvents, Icons.event_outlined, Icons.event),
      (l10n.navMessages, Icons.chat_bubble_outline, Icons.chat_bubble),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(tabs[shell.currentIndex].$1),
        actions: [
          IconButton(
            tooltip: l10n.notificationsTitle,
            icon: const Icon(Icons.notifications_none),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Tapping the current tab again pops it back to its root.
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: [
          for (final (label, icon, selectedIcon) in tabs)
            NavigationDestination(
              icon: Icon(icon),
              selectedIcon: Icon(selectedIcon),
              label: label,
            ),
        ],
      ),
    );
  }
}
