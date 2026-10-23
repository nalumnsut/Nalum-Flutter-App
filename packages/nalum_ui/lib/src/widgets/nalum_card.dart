import 'package:flutter/material.dart';
import 'package:nalum_ui/src/theme/nalum_theme_extension.dart';
import 'package:nalum_ui/src/tokens/nalum_spacing.dart';

/// White card on the off-white surface with the level-1 shadow
/// (design.md "Cards").
class NalumCard extends StatelessWidget {
  const NalumCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(NalumSpacing.md),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(NalumRadii.card);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: context.nalum.cardShadow,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
