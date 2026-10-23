import 'package:flutter_riverpod/misc.dart';
import 'package:nalum_app/core/config/app_env.dart';
import 'package:nalum_app/core/network/dio_provider.dart';
import 'package:nalum_app/features/auth/application/auth_controller.dart';

/// Composition root: the overrides that wire core interfaces to their
/// feature implementations (docs/ARCHITECTURE.md §4.2). Used by `bootstrap()`
/// and by widget tests, so the two can never drift apart.
List<Override> appOverrides({required AppEnv env}) => [
  appEnvProvider.overrideWithValue(env),
  sessionRefresherProvider.overrideWith(
    (ref) => ref.watch(authControllerProvider.notifier),
  ),
];
