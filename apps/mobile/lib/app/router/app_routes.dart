import 'package:nalum_app/features/auth/domain/session_gate.dart';

/// Every app path. The scheme mirrors the website's URLs so one link works
/// for web, Universal/App Links and push payloads (docs/NAVIGATION.md §1).
abstract final class AppRoutes {
  static const splash = '/splash';

  // Public (signed-out) routes.
  static const login = '/login';
  static const signUp = '/signup';
  static const forgotPassword = '/forgot-password';

  // Gate routes (docs/AUTH.md §5).
  static const verifyEmail = '/verify-email';
  static const banned = '/banned';
  static const adminWeb = '/admin-web';
  static const profileSetup = '/onboarding/profile';
  static const verifyAlumni = '/verify-alumni';

  // Tabs.
  static const home = '/home';
  static const directory = '/directory';
  static const posts = '/posts';
  static const events = '/events';
  static const chat = '/chat';

  // Full-screen routes above the tabs.
  static const notifications = '/notifications';
  static const settings = '/settings';
  static String directoryUser(String userId) => '$directory/$userId';
  static String post(String postId) => '$posts/$postId';
  static String event(String eventId) => '$events/$eventId';
  static String conversation(String conversationId) => '$chat/$conversationId';

  static const Set<String> _public = {login, signUp, forgotPassword};
  static const Set<String> _gates = {
    verifyEmail,
    banned,
    adminWeb,
    profileSetup,
    verifyAlumni,
  };

  static bool isPublic(String path) => _public.contains(path);
  static bool isGate(String path) => _gates.contains(path);

  /// The route a gate sends the user to; null when [gate] is ready.
  static String? forGate(SessionGate gate) => switch (gate) {
    SessionGate.banned => banned,
    SessionGate.emailUnverified => verifyEmail,
    SessionGate.verificationExpired => verifyEmail,
    SessionGate.adminWebOnly => adminWeb,
    SessionGate.profileIncomplete => profileSetup,
    SessionGate.alumniUnverified => verifyAlumni,
    SessionGate.ready => null,
  };
}
