import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nalum_app/app/app.dart';
import 'package:nalum_app/app/providers.dart';
import 'package:nalum_app/core/config/app_env.dart';
import 'package:nalum_app/core/storage/token_store.dart';
import 'package:nalum_app/features/auth/data/auth_repository.dart';

import '../helpers/fakes.dart';

const _env = AppEnv(
  flavor: Flavor.prod,
  apiBaseUrl: 'https://api.test/api',
  socketUrl: 'https://api.test',
  webBaseUrl: 'https://alumni.nsut.ac.in',
);

Future<void> pumpApp(
  WidgetTester tester, {
  required TokenStore store,
  required AuthRepository repository,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...appOverrides(env: _env),
        tokenStoreProvider.overrideWithValue(store),
        authRepositoryProvider.overrideWithValue(repository),
      ],
      child: const NalumApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('signed-out start lands on the sign-in form', (tester) async {
    await pumpApp(
      tester,
      store: InMemoryTokenStore(),
      repository: FakeAuthRepository(),
    );

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('signing in moves to the home tab', (tester) async {
    final repository = FakeAuthRepository(
      onSignIn: (_, _) async => testSession(),
    );
    await pumpApp(tester, store: InMemoryTokenStore(), repository: repository);

    await tester.enterText(find.byType(TextFormField).first, 'a@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('an unverified alumnus is held at verification', (tester) async {
    final repository = FakeAuthRepository(
      onRefresh: (_) async =>
          testSession(user: testUser(verifiedAlumni: false)),
    );
    await pumpApp(
      tester,
      store: InMemoryTokenStore('stored'),
      repository: repository,
    );

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Verify you are an alumnus'), findsWidgets);
  });

  testWidgets('tabs switch and keep the shell', (tester) async {
    await pumpApp(
      tester,
      store: InMemoryTokenStore('stored'),
      repository: FakeAuthRepository(onRefresh: (_) async => testSession()),
    );

    await tester.tap(find.text('Events'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Events'), findsWidgets);
  });
}
