import 'package:flutter/widgets.dart';
import 'package:nalum_app/l10n/generated/app_localizations.dart';

export 'package:nalum_app/l10n/generated/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// All user-facing text comes from here (AGENTS.md "Conventions" → Code).
  AppLocalizations get l10n => AppLocalizations.of(this);
}
