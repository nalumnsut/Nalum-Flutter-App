import 'package:flutter/material.dart';
import 'package:nalum_ui/src/tokens/nalum_colors.dart';

/// Tokens that have no slot in [ThemeData] (shadows, borders).
@immutable
class NalumThemeExtension extends ThemeExtension<NalumThemeExtension> {
  const NalumThemeExtension({
    required this.cardShadow,
    required this.overlayShadow,
    required this.border,
  });

  /// Level 1 and level 2 from design.md "Elevation & Depth".
  static const light = NalumThemeExtension(
    cardShadow: [
      BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, 4)),
    ],
    overlayShadow: [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 32,
        offset: Offset(0, 12),
      ),
    ],
    border: NalumColors.border,
  );

  /// Shadows barely read on dark surfaces; tonal contrast does the work.
  static const dark = NalumThemeExtension(
    cardShadow: [],
    overlayShadow: [
      BoxShadow(
        color: Color(0x66000000),
        blurRadius: 32,
        offset: Offset(0, 12),
      ),
    ],
    border: Color(0xFF3A3F45),
  );

  final List<BoxShadow> cardShadow;
  final List<BoxShadow> overlayShadow;
  final Color border;

  @override
  NalumThemeExtension copyWith({
    List<BoxShadow>? cardShadow,
    List<BoxShadow>? overlayShadow,
    Color? border,
  }) {
    return NalumThemeExtension(
      cardShadow: cardShadow ?? this.cardShadow,
      overlayShadow: overlayShadow ?? this.overlayShadow,
      border: border ?? this.border,
    );
  }

  @override
  NalumThemeExtension lerp(NalumThemeExtension? other, double t) {
    if (other == null) return this;
    return NalumThemeExtension(
      cardShadow: BoxShadow.lerpList(cardShadow, other.cardShadow, t) ?? [],
      overlayShadow:
          BoxShadow.lerpList(overlayShadow, other.overlayShadow, t) ?? [],
      border: Color.lerp(border, other.border, t) ?? border,
    );
  }
}

extension NalumThemeContext on BuildContext {
  /// Always present: both [ThemeData]s built by `NalumTheme` register it.
  NalumThemeExtension get nalum =>
      Theme.of(this).extension<NalumThemeExtension>()!;
}
