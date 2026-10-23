import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nalum_app/core/logging/app_logger.dart';
import 'package:nalum_app/core/network/app_failure.dart';
import 'package:nalum_app/core/network/auth_interceptor.dart';
import 'package:nalum_app/core/network/dio_provider.dart';
import 'package:nalum_app/core/storage/token_store.dart';
import 'package:nalum_app/features/auth/data/auth_repository.dart';
import 'package:nalum_app/features/auth/domain/auth_status.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthStatus>(
  AuthController.new,
);

/// Owns the session lifecycle (docs/AUTH.md §3). The only code that writes
/// tokens.
class AuthController extends Notifier<AuthStatus> implements SessionRefresher {
  @override
  AuthStatus build() {
    unawaited(Future.microtask(restore));
    return const AuthUnknown();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);
  TokenStore get _store => ref.read(tokenStoreProvider);
  AccessTokenHolder get _accessToken => ref.read(accessTokenHolderProvider);

  /// Cold start, and the splash screen's retry.
  Future<void> restore() async {
    state = const AuthUnknown();
    final refreshToken = await _store.readRefreshToken();
    if (refreshToken == null) {
      state = const AuthSignedOut();
      return;
    }
    try {
      await _accept(await _repository.refresh(refreshToken));
    } on UnauthorizedFailure {
      await _forget();
    } on AppFailure catch (failure) {
      // Keep the refresh token: being offline is not a reason to sign out.
      AppLogger.info('Session restore failed: ${failure.runtimeType}');
      state = const AuthRestoreFailed();
    }
  }

  /// Returns null on success, otherwise the failure for the form to show.
  Future<AppFailure?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _accept(await _repository.signIn(email: email, password: password));
      return null;
    } on AppFailure catch (failure) {
      return failure;
    }
  }

  Future<void> signOut() async {
    final refreshToken = await _store.readRefreshToken();
    await _forget();
    try {
      await _repository.signOut(refreshToken);
    } on AppFailure catch (failure) {
      // Best effort: the local session is already gone.
      AppLogger.info('Server sign-out failed: ${failure.runtimeType}');
    }
  }

  @override
  Future<String?> refreshAccessToken() async {
    final refreshToken = await _store.readRefreshToken();
    if (refreshToken == null) {
      await _forget();
      return null;
    }
    try {
      final session = await _repository.refresh(refreshToken);
      await _accept(session);
      return session.tokens.accessToken;
    } on UnauthorizedFailure {
      await _forget();
      return null;
    } on AppFailure {
      // Transient: fail this request, keep the session.
      return null;
    }
  }

  Future<void> _accept(AuthSession session) async {
    _accessToken.token = session.tokens.accessToken;
    final refreshToken = session.tokens.refreshToken;
    if (refreshToken != null) await _store.writeRefreshToken(refreshToken);
    state = AuthSignedIn(session.user);
  }

  /// Clears every trace of the session on this device (docs/AUTH.md §3.4).
  Future<void> _forget() async {
    _accessToken.token = null;
    await _store.clear();
    state = const AuthSignedOut();
  }
}
