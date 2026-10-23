import 'package:flutter/material.dart';
import 'package:nalum_app/l10n/l10n.dart';
import 'package:nalum_ui/nalum_ui.dart';

/// Posts tab: feed, tags, search, my posts (docs/PLAN.md §1.2). Built in M2/M4.
class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) => EmptyState(
    title: context.l10n.navPosts,
    message: context.l10n.comingSoon,
    icon: Icons.article_outlined,
  );
}
