import 'package:flutter/widgets.dart';

/// 4 px base, 8 px rhythm (design.md "Layout & Spacing").
abstract final class NalumSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Screen side margin on phones (design.md "Mobile Adaptivity").
  static const double screenMargin = md;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenMargin,
  );
}

/// Corner radii (design.md "Shapes").
abstract final class NalumRadii {
  static const double sm = 4;

  /// Buttons and inputs.
  static const double control = 8;
  static const double md = 12;

  /// Cards and major containers.
  static const double card = 16;
  static const double xl = 24;
  static const double pill = 9999;
}
