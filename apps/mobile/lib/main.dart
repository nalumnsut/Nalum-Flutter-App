import 'package:nalum_app/bootstrap.dart';
import 'package:nalum_app/core/config/app_env.dart';

/// Run with a flavor config, e.g.
/// `flutter run --flavor dev --dart-define-from-file=config/dev.json`
/// (AGENTS.md "Commands").
Future<void> main() => bootstrap(AppEnv.fromEnvironment());
