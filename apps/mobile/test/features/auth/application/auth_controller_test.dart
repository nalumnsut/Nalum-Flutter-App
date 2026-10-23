import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nalum_app/core/network/app_failure.dart';
import 'package:nalum_app/core/network/dio_provider.dart';
import 'package:nalum_app/core/storage/token_store.dart';
import 'package:nalum_app/features/auth/application/auth_controller.dart';
import 'package:nalum_app/features/auth/data/auth_repository.dart';
import 'package:nalum_app/features/auth/domain/auth_status.dart';

import '../../../helpers/fakes.dart';

void main() {
  late InMemoryTokenStore store;
  late FakeAuthRepository repository;

  ProviderContainer container() {
    final container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(store),
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// Reads the controller and lets the restore scheduled in build() finish.
  Future<AuthStatus> settle(ProviderContainer c) async {
    c.read(authControllerProvider);
    await pumpEventQueue();
    return c.read(authControllerProvider);
  }

  setUp(() {
    store = InMemoryTokenStore();
    repository = FakeAuthRepository();
  });

  test('no stored token → signed out without calling the server', () async {
    expect(await settle(container()), isA<AuthSignedOut>());
    expect(repository.refreshCalls, 0);
  });

  test('stored token → restored session, token rotated', () async {
    store.refreshToken = 'old';
    repository.onRefresh = (_) async => testSession();
    final c = container();

    expect(await settle(c), isA<AuthSignedIn>());
    expect(store.refreshToken, 'refresh-1');
    expect(c.read(accessTokenHolderProvider).token, 'access-1');
  });

  test('offline on start keeps the token and offers retry', () async {
    store.refreshToken = 'old';
    repository.onRefresh = (_) async => throw const NetworkFailure();

    expect(await settle(container()), isA<AuthRestoreFailed>());
    expect(store.refreshToken, 'old');
  });

  test('rejected token signs out and wipes it', () async {
    store.refreshToken = 'old';
    repository.onRefresh = (_) async =>
        throw const UnauthorizedFailure('UNAUTHORIZED');

    expect(await settle(container()), isA<AuthSignedOut>());
    expect(store.refreshToken, isNull);
  });

  test('sign-in failure is returned, state unchanged', () async {
    repository.onSignIn = (_, _) async =>
        throw const UnauthorizedFailure('UNKNOWN');
    final c = container();
    await settle(c);

    final failure = await c
        .read(authControllerProvider.notifier)
        .signIn(email: 'a@example.com', password: 'x');

    expect(failure, isA<UnauthorizedFailure>());
    expect(c.read(authControllerProvider), isA<AuthSignedOut>());
  });

  test('sign-out clears locally even if the server call fails', () async {
    store.refreshToken = 'old';
    repository.onRefresh = (_) async => testSession();
    final c = container();
    await settle(c);

    await c.read(authControllerProvider.notifier).signOut();

    expect(c.read(authControllerProvider), isA<AuthSignedOut>());
    expect(store.refreshToken, isNull);
    expect(c.read(accessTokenHolderProvider).token, isNull);
    expect(repository.signOutCalls, 1);
  });

  test('a transient refresh failure does not sign out', () async {
    store.refreshToken = 'old';
    repository.onRefresh = (_) async => testSession();
    final c = container();
    await settle(c);
    repository.onRefresh = (_) async => throw const NetworkFailure();

    final token = await c
        .read(authControllerProvider.notifier)
        .refreshAccessToken();

    expect(token, isNull);
    expect(c.read(authControllerProvider), isA<AuthSignedIn>());
  });
}
