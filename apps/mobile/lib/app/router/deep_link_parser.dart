import 'package:nalum_app/app/router/app_routes.dart';

/// Maps an incoming link (Universal/App Link, push `route`, notification
/// `actionUrl`) to an in-app location, or null if the app does not handle it
/// and it should open in the browser (docs/NAVIGATION.md §3).
///
/// Accepts both the website's `/dashboard/...` paths and the app's own paths.
String? appLocationForLink(Uri uri, {required Set<String> trustedHosts}) {
  if (uri.hasScheme) {
    if (uri.scheme != 'https' && uri.scheme != 'http') return null;
    if (!trustedHosts.contains(uri.host)) return null;
  }

  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  // Ids come from untrusted links; anything odd is rejected rather than
  // passed into a route.
  if (!segments.every(_safeSegment.hasMatch)) return null;
  if (segments.isEmpty) return AppRoutes.home;

  if (segments.first == 'dashboard') {
    return _fromWebDashboard(segments.sublist(1), uri.queryParameters);
  }
  if (segments.length == 1 && segments.first == 'map') return '/map';
  if (_appRoots.contains(segments.first)) {
    return '/${segments.join('/')}';
  }
  return null;
}

final _safeSegment = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

const _appRoots = {
  'home',
  'directory',
  'connections',
  'chat',
  'posts',
  'events',
  'notifications',
  'queries',
  'resources',
  'profile',
  'settings',
  'map',
};

String? _fromWebDashboard(List<String> rest, Map<String, String> query) {
  if (rest.isEmpty) return AppRoutes.home;
  final tail = rest.sublist(1);
  final myTab = query['tab'] == 'my';

  switch (rest.first) {
    case 'alumni':
      if (tail.isEmpty) return myTab ? '/connections' : AppRoutes.directory;
      return tail.length == 1 ? AppRoutes.directoryUser(tail.first) : null;
    case 'connections':
      return '/connections';
    case 'chat':
      if (tail.isEmpty) return AppRoutes.chat;
      return tail.length == 1 ? AppRoutes.conversation(tail.first) : null;
    case 'posts':
      if (tail.isEmpty) {
        return myTab ? '${AppRoutes.posts}?tab=my' : AppRoutes.posts;
      }
      return _detail(AppRoutes.posts, tail);
    case 'my-posts':
      return '${AppRoutes.posts}?tab=my';
    case 'events':
      if (tail.isEmpty) {
        return myTab ? '${AppRoutes.events}?tab=my' : AppRoutes.events;
      }
      return _detail(AppRoutes.events, tail);
    case 'host-event':
      return '${AppRoutes.events}/new';
    case 'notifications':
      return AppRoutes.notifications;
    case 'queries':
      return '/queries';
    case 'resources':
      return '/resources';
    case 'profile':
      return '/profile';
    case 'update-profile':
      return '/profile/edit';
    case 'verify-alumni':
      return AppRoutes.verifyAlumni;
    case 'change-password':
      return '${AppRoutes.settings}/password';
  }
  return null;
}

/// `<root>/new`, `<root>/<id>` and `<root>/<id>/edit`.
String? _detail(String root, List<String> tail) {
  if (tail.length == 1) return '$root/${tail.first}';
  if (tail.length == 2 && tail.last == 'edit') {
    return '$root/${tail.first}/edit';
  }
  return null;
}
