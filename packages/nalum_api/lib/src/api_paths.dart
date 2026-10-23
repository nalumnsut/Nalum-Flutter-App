/// Endpoint paths, relative to the API base URL (which already ends in `/api`).
///
/// Paths marked "Proposed" do not exist on today's backend; docs/API.md §4
/// lists the backend work that adds them.
abstract final class ApiPaths {
  // Auth (docs/AUTH.md §2).
  static const signIn = '/auth/sign-in';
  static const signUp = '/auth/sign-up';
  static const refresh = '/auth/refresh';
  static const logout = '/auth/logout';
  static const google = '/auth/google';

  /// Proposed: Sign in with Apple (docs/AUTH.md §4).
  static const apple = '/auth/apple';
  static const sendOtp = '/auth/send-otp';
  static const verifyOtp = '/auth/verify-account-otp';
  static const forgotPassword = '/auth/forget-password';
  static const changePassword = '/auth/change-password';
  static const deleteAccount = '/auth/account';

  /// Proposed: current user + capabilities (docs/API.md §4).
  static const me = '/me';

  /// Proposed: push device registration (docs/NOTIFICATIONS.md §3).
  static const devices = '/me/devices';

  /// Proposed: remote config and minimum supported version (docs/API.md §4).
  static const appConfig = '/app-config';

  // Profiles.
  static const myProfile = '/profile/me';
  static const profileStatus = '/profile/status';
  static String userProfile(String userId) => '/profile/user/$userId';
  static const profileSearch = '/profile/search';
  static const profileSuggestions = '/profile/suggestions';

  // Content.
  static const posts = '/posts';
  static String post(String postId) => '/posts/$postId';
  static const approvedEvents = '/events/approved';
  static String event(String eventId) => '/events/$eventId';
  static const notifications = '/notifications';
  static const notificationsUnreadCount = '/notifications/unread-count';

  /// Health check, used by the splash screen's retry.
  static const health = '/health';
}
