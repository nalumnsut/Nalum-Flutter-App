/// Machine-readable error codes the app branches on (docs/API.md §3.2).
///
/// A newer backend may send codes an older app has never seen, and that must
/// not crash it, so codes are plain strings compared against these constants
/// rather than an enum.
abstract final class ApiErrorCode {
  static const unauthorized = 'UNAUTHORIZED';
  static const tokenExpired = 'TOKEN_EXPIRED';
  static const invalidCredentials = 'INVALID_CREDENTIALS';
  static const emailNotVerified = 'EMAIL_NOT_VERIFIED';
  static const banned = 'BANNED';
  static const verificationExpired = 'VERIFICATION_EXPIRED';
  static const alumniUnverified = 'ALUMNI_UNVERIFIED';
  static const profileIncomplete = 'PROFILE_INCOMPLETE';
  static const googleAccount = 'GOOGLE_ACCOUNT';
  static const rateLimited = 'RATE_LIMITED';
  static const validationFailed = 'VALIDATION_FAILED';
  static const notFound = 'NOT_FOUND';
  static const forbidden = 'FORBIDDEN';
  static const upgradeRequired = 'UPGRADE_REQUIRED';

  /// Used when a legacy response carries no code at all.
  static const unknown = 'UNKNOWN';
}
