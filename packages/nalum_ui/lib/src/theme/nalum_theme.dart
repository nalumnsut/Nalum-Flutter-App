import 'package:flutter/material.dart';
import 'package:nalum_ui/src/theme/nalum_theme_extension.dart';
import 'package:nalum_ui/src/tokens/nalum_colors.dart';
import 'package:nalum_ui/src/tokens/nalum_spacing.dart';
import 'package:nalum_ui/src/tokens/nalum_typography.dart';

/// Builds the app's [ThemeData]. Screens read colors and text styles from
/// `Theme.of(context)`; they never hard-code values (docs/DESIGN_SYSTEM.md §1).
abstract final class NalumTheme {
  static ThemeData light() => _build(
    NalumColorSchemes.light,
    NalumThemeExtension.light,
  );

  static ThemeData dark() => _build(
    NalumColorSchemes.dark,
    NalumThemeExtension.dark,
  );

  static ThemeData _build(ColorScheme scheme, NalumThemeExtension extension) {
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(NalumRadii.control),
    );
    final textTheme = NalumTypography.textTheme(scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: NalumTypography.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [extension],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NalumRadii.card),
          side: BorderSide(color: extension.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // design.md: primary buttons are the brand crimson.
          backgroundColor: scheme.brightness == Brightness.light
              ? NalumColors.primaryContainer
              : scheme.primary,
          foregroundColor: scheme.brightness == Brightness.light
              ? NalumColors.onPrimary
              : scheme.onPrimary,
          minimumSize: const Size(64, 48),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: controlShape,
          side: BorderSide(color: extension.border),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NalumRadii.control),
          borderSide: BorderSide(color: extension.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NalumRadii.control),
          borderSide: BorderSide(color: extension.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NalumRadii.control),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: extension.border),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        indicatorColor: scheme.secondaryContainer,
      ),
    );
  }
}
