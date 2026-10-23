import 'package:nalum_api/nalum_api.dart';
import 'package:nalum_app/core/network/app_failure.dart';
import 'package:nalum_app/l10n/l10n.dart';

/// User-facing text for a failure. Server messages are never shown: they can
/// leak internals and are not localized (AGENTS.md "Hard rules" → Privacy).
String failureText(AppLocalizations l10n, AppFailure failure) {
  return switch (failure) {
    NetworkFailure() => l10n.errorNetwork,
    UnauthorizedFailure() => l10n.errorSessionExpired,
    ForbiddenFailure(code: ApiErrorCode.banned) => l10n.errorBanned,
    RateLimitedFailure() => l10n.errorRateLimited,
    UpgradeRequiredFailure() => l10n.errorUpgradeRequired,
    ForbiddenFailure() ||
    NotFoundFailure() ||
    ValidationFailure() ||
    ServerFailure() ||
    UnexpectedFailure() => l10n.errorGeneric,
  };
}
