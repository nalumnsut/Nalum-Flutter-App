import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nalum_ui/nalum_ui.dart';

void main() {
  test('light theme uses the design.md tokens', () {
    final theme = NalumTheme.light();

    expect(theme.colorScheme.primary, NalumColors.primary);
    expect(theme.colorScheme.surface, NalumColors.surface);
    expect(theme.extension<NalumThemeExtension>(), isNotNull);
  });

  test('dark theme registers the extension too', () {
    expect(NalumTheme.dark().extension<NalumThemeExtension>(), isNotNull);
  });

  testWidgets('ErrorState shows retry and calls back', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: NalumTheme.light(),
        home: Scaffold(
          body: ErrorState(
            message: 'Something went wrong',
            retryLabel: 'Retry',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('NalumCard renders in both themes', (tester) async {
    for (final theme in [NalumTheme.light(), NalumTheme.dark()]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: NalumCard(child: Text('Card'))),
        ),
      );
      expect(find.text('Card'), findsOneWidget);
    }
  });
}
