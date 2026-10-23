import 'package:flutter/material.dart';
import 'package:nalum_app/l10n/l10n.dart';
import 'package:nalum_ui/nalum_ui.dart';

/// Messages tab: conversations and communities (docs/CHAT.md). Built in M3.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) => EmptyState(
    title: context.l10n.navMessages,
    message: context.l10n.comingSoon,
    icon: Icons.chat_bubble_outline,
  );
}
