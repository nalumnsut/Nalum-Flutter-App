import 'package:nalum_app/app/router/app_routes.dart';
import 'package:nalum_app/features/auth/domain/auth_status.dart';
import 'package:nalum_app/features/auth/domain/session_gate.dart';

/// The single router guard (docs/NAVIGATION.md §2). Pure, so every branch is
/// unit-tested; returns the location to go to, or null to stay.
///
/// A deep link opened while signed out or during cold start is kept in the
/// `from` query parameter and resumed once the user is ready.
String? authRedirect(AuthStatus status, Uri location) {
  final path = location.path;

  switch (status) {
    case AuthUnknown():
    case AuthRestoreFailed():
      if (path == AppRoutes.splash) return null;
      return _withFrom(AppRoutes.splash, location);

    case AuthSignedOut():
      if (AppRoutes.isPublic(path)) return null;
      return _withFrom(AppRoutes.login, location);

    case AuthSignedIn(:final user):
      final gateRoute = AppRoutes.forGate(gateFor(user));
      if (gateRoute != null) {
        return path == gateRoute ? null : gateRoute;
      }
      final leavingAuthFlow =
          path == AppRoutes.splash ||
          AppRoutes.isPublic(path) ||
          AppRoutes.isGate(path);
      if (!leavingAuthFlow) return null;
      return _safeFrom(location) ?? AppRoutes.home;
  }
}

String _withFrom(String target, Uri location) {
  final carried = _resumable(location)
      ? location.toString()
      : location.queryParameters['from'];
  if (carried == null) return target;
  return Uri(path: target, queryParameters: {'from': carried}).toString();
}

/// Only in-app, non-auth paths are resumed: `from` is user-controllable via
/// links, so it must never send the user somewhere unexpected.
String? _safeFrom(Uri location) {
  final from = location.queryParameters['from'];
  if (from == null) return null;
  final uri = Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
  return _resumable(uri) ? from : null;
}

bool _resumable(Uri location) {
  final path = location.path;
  return path.startsWith('/') &&
      path != AppRoutes.splash &&
      !AppRoutes.isPublic(path) &&
      !AppRoutes.isGate(path);
}
