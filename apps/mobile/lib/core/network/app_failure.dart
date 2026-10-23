/// Every error that crosses a repository boundary is one of these
/// (docs/ARCHITECTURE.md §5). Screens switch over them exhaustively.
sealed class AppFailure implements Exception {
  const AppFailure();
}

/// No connection, DNS failure, timeout.
final class NetworkFailure extends AppFailure {
  const NetworkFailure();
}

/// 401: missing, expired or invalid credentials/session.
final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure(this.code);
  final String code;
}

/// 403: authenticated but not allowed (banned, unverified, wrong role).
final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure(this.code);
  final String code;
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure();
}

/// 400/422 with per-field problems.
final class ValidationFailure extends AppFailure {
  const ValidationFailure(this.code, this.fields);
  final String code;
  final Map<String, String> fields;
}

final class RateLimitedFailure extends AppFailure {
  const RateLimitedFailure();
}

/// 426: this app version is below the server's minimum (docs/API.md §3.4).
final class UpgradeRequiredFailure extends AppFailure {
  const UpgradeRequiredFailure();
}

final class ServerFailure extends AppFailure {
  const ServerFailure(this.statusCode);
  final int statusCode;
}

/// Anything else, including malformed responses. Always worth a crash report.
final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure([this.cause]);
  final Object? cause;
}
