import 'package:nalum_app/core/network/app_failure.dart';
import 'package:nalum_app/core/storage/token_store.dart';
import 'package:nalum_app/features/auth/data/auth_repository.dart';
import 'package:nalum_app/features/auth/domain/auth_status.dart';
import 'package:nalum_app/features/auth/domain/session_user.dart';

/// Test users. Names and ids are made up (AGENTS.md "Conventions" → Tests:
/// no real people in fixtures).
SessionUser testUser({
  UserRole role = UserRole.alumni,
  bool emailVerified = true,
  bool profileCompleted = true,
  bool verifiedAlumni = true,
  bool banned = false,
  bool verificationExpired = false,
}) {
  return SessionUser(
    id: 'user-1',
    name: 'Test User',
    role: role,
    emailVerified: emailVerified,
    profileCompleted: profileCompleted,
    verifiedAlumni: verifiedAlumni,
    banned: banned,
    verificationExpired: verificationExpired,
  );
}

AuthSession testSession({SessionUser? user, String access = 'access-1'}) {
  return AuthSession(
    tokens: SessionTokens(accessToken: access, refreshToken: 'refresh-1'),
    user: user ?? testUser(),
  );
}

class InMemoryTokenStore implements TokenStore {
  InMemoryTokenStore([this.refreshToken]);

  String? refreshToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> writeRefreshToken(String token) async => refreshToken = token;

  @override
  Future<void> clear() async => refreshToken = null;
}

/// Each call answers from the matching callback; unset callbacks fail loudly.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.onSignIn, this.onRefresh});

  Future<AuthSession> Function(String email, String password)? onSignIn;
  Future<AuthSession> Function(String refreshToken)? onRefresh;
  int refreshCalls = 0;
  int signOutCalls = 0;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) =>
      (onSignIn ??
      (_, _) => throw const UnexpectedFailure('signIn not stubbed'))(
        email,
        password,
      );

  @override
  Future<AuthSession> refresh(String refreshToken) {
    refreshCalls++;
    return (onRefresh ??
        (_) =>
            throw const UnexpectedFailure('refresh not stubbed'))(refreshToken);
  }

  @override
  Future<void> signOut(String? refreshToken) async => signOutCalls++;
}
