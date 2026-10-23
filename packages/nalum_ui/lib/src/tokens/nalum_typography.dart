import 'package:flutter/material.dart';

/// Type scale from design.md "Typography", mapped onto Material 3 roles
/// (docs/DESIGN_SYSTEM.md §3).
abstract final class NalumTypography {
  /// Bundled font family name. Until the font files are added under
  /// `apps/mobile/assets/fonts/` (docs/DESIGN_SYSTEM.md §3.1) Flutter falls
  /// back to the platform font, which is intentional: no runtime downloads.
  static const fontFamily = 'HankenGrotesk';

  static TextTheme textTheme(Color onSurface) {
    TextStyle style(
      double size,
      double height,
      FontWeight weight, [
      double letterSpacing = 0,
    ]) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        height: height / size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: onSurface,
      );
    }

    return TextTheme(
      // headline-xl
      headlineLarge: style(36, 44, FontWeight.w700, -0.72),
      // headline-lg
      headlineMedium: style(28, 36, FontWeight.w600, -0.28),
      // headline-lg-mobile
      headlineSmall: style(24, 32, FontWeight.w600),
      // headline-md
      titleLarge: style(20, 28, FontWeight.w600),
      titleMedium: style(16, 24, FontWeight.w600),
      titleSmall: style(14, 20, FontWeight.w600),
      // body-lg / body-md / body-sm
      bodyLarge: style(18, 28, FontWeight.w400),
      bodyMedium: style(16, 24, FontWeight.w400),
      bodySmall: style(14, 20, FontWeight.w400),
      // label-md / label-sm
      labelLarge: style(14, 16, FontWeight.w600, 0.28),
      labelMedium: style(12, 16, FontWeight.w600, 0.24),
      labelSmall: style(12, 14, FontWeight.w500),
    );
  }
}
