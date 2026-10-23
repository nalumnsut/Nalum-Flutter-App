import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nalum_app/app/app.dart';
import 'package:nalum_app/app/providers.dart';
import 'package:nalum_app/core/config/app_env.dart';
import 'package:nalum_app/core/logging/app_logger.dart';

/// App start-up: error hooks, then the provider scope. Firebase and
/// Crashlytics initialise here once the org-owned projects exist
/// (docs/RELEASING.md §6).
Future<void> bootstrap(AppEnv env) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error('Flutter error', details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Uncaught error', error, stack);
    return true;
  };

  runApp(
    ProviderScope(
      overrides: appOverrides(env: env),
      child: const NalumApp(),
    ),
  );
}
