import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Flavor { dev, staging, prod }

/// Build-time configuration, read from `--dart-define-from-file=config/<flavor>.json`.
///
/// Only non-secret values belong here: anything compiled into the app can be
/// extracted from it (AGENTS.md "Hard rules" → Security).
@immutable
class AppEnv {
  const AppEnv({
    required this.flavor,
    required this.apiBaseUrl,
    required this.socketUrl,
    required this.webBaseUrl,
  });

  /// Fails fast instead of silently defaulting, so a release build can never
  /// ship pointing at a dev server (docs/RELEASING.md §2).
  factory AppEnv.fromEnvironment() {
    const flavorName = String.fromEnvironment('FLAVOR');
    const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
    const socketUrl = String.fromEnvironment('SOCKET_URL');
    const webBaseUrl = String.fromEnvironment('WEB_BASE_URL');

    if (flavorName.isEmpty || apiBaseUrl.isEmpty) {
      throw StateError(
        'Missing build config. Run with --dart-define-from-file=config/dev.json '
        '(AGENTS.md "Commands").',
      );
    }
    final env = AppEnv(
      flavor: Flavor.values.byName(flavorName),
      apiBaseUrl: apiBaseUrl,
      socketUrl: socketUrl,
      webBaseUrl: webBaseUrl,
    );
    if (env.flavor != Flavor.dev && !apiBaseUrl.startsWith('https://')) {
      throw StateError('Non-dev builds must use an https API URL.');
    }
    return env;
  }

  final Flavor flavor;
  final String apiBaseUrl;
  final String socketUrl;
  final String webBaseUrl;

  /// Hosts whose links the app opens in-app (docs/NAVIGATION.md §3).
  Set<String> get trustedLinkHosts => {
    'alumni.nsut.ac.in',
    Uri.parse(webBaseUrl).host,
  };
}

/// Overridden in `appOverrides()`; reading it without an override is a bug.
final appEnvProvider = Provider<AppEnv>(
  (ref) => throw UnimplementedError('appEnvProvider must be overridden'),
);
