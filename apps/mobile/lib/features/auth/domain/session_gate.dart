import 'package:nalum_app/features/auth/domain/session_user.dart';

/// Where a signed-in user must go before they can use the app
/// (docs/AUTH.md §5). Order matters: earlier gates win.
enum SessionGate {
  banned,
  emailUnverified,
  adminWebOnly,
  verificationExpired,
  profileIncomplete,
  alumniUnverified,
  ready,
}

SessionGate gateFor(SessionUser user) {
  if (user.banned) return SessionGate.banned;
  if (!user.emailVerified) return SessionGate.emailUnverified;
  if (user.role == UserRole.admin) return SessionGate.adminWebOnly;
  if (user.verificationExpired) return SessionGate.verificationExpired;
  if (!user.profileCompleted) return SessionGate.profileIncomplete;
  if (user.role == UserRole.alumni && !user.verifiedAlumni) {
    return SessionGate.alumniUnverified;
  }
  return SessionGate.ready;
}
