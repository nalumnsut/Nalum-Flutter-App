import 'package:meta/meta.dart';
import 'package:nalum_app/features/auth/domain/session_user.dart';

/// App-wide authentication state. The router redirects on every change
/// (docs/AUTH.md §5, docs/NAVIGATION.md §2).
@immutable
sealed class AuthStatus {
  const AuthStatus();
}

/// Cold start: the stored session has not been checked yet.
final class AuthUnknown extends AuthStatus {
  const AuthUnknown();
}

/// The stored session could not be checked (offline, server down). The user
/// is not signed out: their refresh token is kept and they can retry.
final class AuthRestoreFailed extends AuthStatus {
  const AuthRestoreFailed();
}

final class AuthSignedOut extends AuthStatus {
  const AuthSignedOut();
}

final class AuthSignedIn extends AuthStatus {
  const AuthSignedIn(this.user);
  final SessionUser user;
}

@immutable
class SessionTokens {
  const SessionTokens({required this.accessToken, this.refreshToken});
  final String accessToken;

  /// Null when the backend only set it as a cookie (legacy).
  final String? refreshToken;
}

@immutable
class AuthSession {
  const AuthSession({required this.tokens, required this.user});
  final SessionTokens tokens;
  final SessionUser user;
}
