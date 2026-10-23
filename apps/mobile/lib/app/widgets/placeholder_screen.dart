import 'package:flutter/material.dart';
import 'package:nalum_app/l10n/l10n.dart';
import 'package:nalum_ui/nalum_ui.dart';

/// Stand-in for screens that are routed but not built yet. Replace, don't
/// extend: each real screen lives in its feature's `presentation/` folder.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    super.key,
    this.withAppBar = true,
  });

  final String title;

  /// False inside the tab shell, which draws its own app bar.
  final bool withAppBar;

  @override
  Widget build(BuildContext context) {
    final body = EmptyState(
      title: title,
      message: context.l10n.comingSoon,
      icon: Icons.construction_outlined,
    );
    if (!withAppBar) return body;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );
  }
}
