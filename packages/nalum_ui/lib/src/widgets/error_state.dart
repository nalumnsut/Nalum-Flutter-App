import 'package:flutter/material.dart';
import 'package:nalum_ui/src/widgets/empty_state.dart';

/// Full-area error with an optional retry button.
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.message,
    super.key,
    this.onRetry,
    this.retryLabel,
  }) : assert(
         onRetry == null || retryLabel != null,
         'A retry button needs a localized label.',
       );

  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: message,
      icon: Icons.error_outline,
      action: onRetry == null
          ? null
          : OutlinedButton(onPressed: onRetry, child: Text(retryLabel!)),
    );
  }
}
