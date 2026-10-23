import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nalum_app/app/router/app_router.dart';
import 'package:nalum_app/core/config/app_env.dart';
import 'package:nalum_app/l10n/l10n.dart';
import 'package:nalum_ui/nalum_ui.dart';

class NalumApp extends ConsumerWidget {
  const NalumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(appEnvProvider).flavor;
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: NalumTheme.light(),
      darkTheme: NalumTheme.dark(),
      routerConfig: ref.watch(appRouterProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      // Non-prod builds are marked so screenshots and bug reports are never
      // mistaken for production.
      builder: (context, child) => flavor == Flavor.prod
          ? child!
          : Banner(
              message: flavor.name.toUpperCase(),
              location: BannerLocation.topEnd,
              child: child,
            ),
    );
  }
}
