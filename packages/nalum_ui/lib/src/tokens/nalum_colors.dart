import 'package:flutter/material.dart';

/// Color tokens copied from the website's `design.md` front matter.
///
/// design.md already uses Material 3 role names, so each token maps 1:1 onto
/// a [ColorScheme] role (docs/DESIGN_SYSTEM.md §2). Do not add colors here
/// that are not in design.md; add them there first.
abstract final class NalumColors {
  static const primary = Color(0xFF6E0000);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF990000);
  static const onPrimaryContainer = Color(0xFFFFA092);
  static const inversePrimary = Color(0xFFFFB4A8);
  static const surfaceTint = Color(0xFFB82014);

  static const secondary = Color(0xFF545F72);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFD5E0F7);
  static const onSecondaryContainer = Color(0xFF586377);

  static const tertiary = Color(0xFF293344);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF404A5C);
  static const onTertiaryContainer = Color(0xFFAFBACF);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const surface = Color(0xFFF8F9FA);
  static const surfaceDim = Color(0xFFD9DADB);
  static const surfaceBright = Color(0xFFF8F9FA);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainer = Color(0xFFEDEEEF);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  static const surfaceContainerHighest = Color(0xFFE1E3E4);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF5B403C);
  static const inverseSurface = Color(0xFF2E3132);
  static const onInverseSurface = Color(0xFFF0F1F2);
  static const outline = Color(0xFF8F706B);
  static const outlineVariant = Color(0xFFE4BEB8);

  /// The brand crimson from design.md "Colors" (#990000). Used as the seed
  /// for the dark scheme, which design.md does not define yet.
  static const Color brand = primaryContainer;

  /// Card and input border ("light slate tint", design.md "Elevation").
  static const border = Color(0xFFE2E8F0);
}

abstract final class NalumColorSchemes {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: NalumColors.primary,
    onPrimary: NalumColors.onPrimary,
    primaryContainer: NalumColors.primaryContainer,
    onPrimaryContainer: NalumColors.onPrimaryContainer,
    inversePrimary: NalumColors.inversePrimary,
    surfaceTint: NalumColors.surfaceTint,
    secondary: NalumColors.secondary,
    onSecondary: NalumColors.onSecondary,
    secondaryContainer: NalumColors.secondaryContainer,
    onSecondaryContainer: NalumColors.onSecondaryContainer,
    tertiary: NalumColors.tertiary,
    onTertiary: NalumColors.onTertiary,
    tertiaryContainer: NalumColors.tertiaryContainer,
    onTertiaryContainer: NalumColors.onTertiaryContainer,
    error: NalumColors.error,
    onError: NalumColors.onError,
    errorContainer: NalumColors.errorContainer,
    onErrorContainer: NalumColors.onErrorContainer,
    surface: NalumColors.surface,
    surfaceDim: NalumColors.surfaceDim,
    surfaceBright: NalumColors.surfaceBright,
    surfaceContainerLowest: NalumColors.surfaceContainerLowest,
    surfaceContainerLow: NalumColors.surfaceContainerLow,
    surfaceContainer: NalumColors.surfaceContainer,
    surfaceContainerHigh: NalumColors.surfaceContainerHigh,
    surfaceContainerHighest: NalumColors.surfaceContainerHighest,
    onSurface: NalumColors.onSurface,
    onSurfaceVariant: NalumColors.onSurfaceVariant,
    inverseSurface: NalumColors.inverseSurface,
    onInverseSurface: NalumColors.onInverseSurface,
    outline: NalumColors.outline,
    outlineVariant: NalumColors.outlineVariant,
  );

  /// Provisional: generated from the brand seed until design signs off on
  /// dark tokens (docs/DESIGN_SYSTEM.md §2.2).
  static final dark = ColorScheme.fromSeed(
    seedColor: NalumColors.brand,
    brightness: Brightness.dark,
  );
}
