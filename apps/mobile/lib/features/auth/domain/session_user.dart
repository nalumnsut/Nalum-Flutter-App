import 'package:meta/meta.dart';

enum UserRole {
  student,
  faculty,
  alumni,
  admin
  ;

  /// Unknown roles fall back to the least-privileged one, matching the
  /// backend's `protect` middleware default.
  static UserRole parse(String raw) =>
      values.firstWhere((role) => role.name == raw, orElse: () => student);
}

/// The signed-in user as the app needs it. Built from `/me` (proposed) or,
/// until that exists, from the user object in auth responses.
@immutable
class SessionUser {
  const SessionUser({
    required this.id,
    required this.name,
    required this.role,
    required this.emailVerified,
    required this.profileCompleted,
    required this.verifiedAlumni,
    this.hasPassword = true,
    this.banned = false,
    this.verificationExpired = false,
  });

  final String id;
  final String name;
  final UserRole role;
  final bool emailVerified;
  final bool profileCompleted;
  final bool verifiedAlumni;

  /// False for Google/Apple-only accounts: hides "Change password".
  final bool hasPassword;
  final bool banned;

  /// Students and faculty must re-verify their NSUT email every 180 days.
  final bool verificationExpired;

  // Transitional: these mirror the website's role rules (docs/PLAN.md §1.1)
  // until the backend returns capabilities from /me (docs/API.md §4).
  bool get canPost =>
      role == UserRole.admin ||
      role == UserRole.faculty ||
      (role == UserRole.alumni && verifiedAlumni);

  bool get canHostEvent =>
      role == UserRole.faculty || (role == UserRole.alumni && verifiedAlumni);
}
