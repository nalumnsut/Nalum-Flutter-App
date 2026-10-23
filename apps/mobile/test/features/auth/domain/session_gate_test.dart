import 'package:flutter_test/flutter_test.dart';
import 'package:nalum_app/features/auth/domain/session_gate.dart';
import 'package:nalum_app/features/auth/domain/session_user.dart';

import '../../../helpers/fakes.dart';

void main() {
  test('gate order: banned beats everything', () {
    expect(
      gateFor(testUser(banned: true, emailVerified: false)),
      SessionGate.banned,
    );
  });

  test('email verification comes before profile and alumni checks', () {
    expect(
      gateFor(testUser(emailVerified: false, profileCompleted: false)),
      SessionGate.emailUnverified,
    );
  });

  test('profile completion comes before alumni verification', () {
    expect(
      gateFor(testUser(profileCompleted: false, verifiedAlumni: false)),
      SessionGate.profileIncomplete,
    );
  });

  test('alumni verification only applies to alumni', () {
    expect(
      gateFor(testUser(verifiedAlumni: false)),
      SessionGate.alumniUnverified,
    );
    expect(
      gateFor(testUser(role: UserRole.student, verifiedAlumni: false)),
      SessionGate.ready,
    );
  });

  test('expired NSUT email verification is its own gate', () {
    expect(
      gateFor(testUser(role: UserRole.faculty, verificationExpired: true)),
      SessionGate.verificationExpired,
    );
  });

  test('admins are sent to the web panel', () {
    expect(gateFor(testUser(role: UserRole.admin)), SessionGate.adminWebOnly);
  });

  test('unknown roles are treated as students', () {
    expect(UserRole.parse('superuser'), UserRole.student);
  });

  test('capabilities follow the website rules', () {
    expect(testUser().canPost, isTrue);
    expect(testUser(verifiedAlumni: false).canPost, isFalse);
    expect(testUser(role: UserRole.student).canPost, isFalse);
    expect(testUser(role: UserRole.student).canHostEvent, isFalse);
    expect(testUser(role: UserRole.faculty).canHostEvent, isTrue);
  });
}
