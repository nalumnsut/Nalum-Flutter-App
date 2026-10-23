import 'package:flutter_test/flutter_test.dart';
import 'package:nalum_app/app/router/app_routes.dart';
import 'package:nalum_app/app/router/auth_redirect.dart';
import 'package:nalum_app/features/auth/domain/auth_status.dart';
import 'package:nalum_app/features/auth/domain/session_user.dart';

import '../../helpers/fakes.dart';

void main() {
  String? redirect(AuthStatus status, String location) =>
      authRedirect(status, Uri.parse(location));

  group('while the session is being checked', () {
    test('everything goes to splash and remembers where it was going', () {
      expect(
        redirect(const AuthUnknown(), '/posts/abc'),
        '/splash?from=%2Fposts%2Fabc',
      );
      expect(redirect(const AuthUnknown(), '/splash'), isNull);
      expect(
        redirect(const AuthRestoreFailed(), '/home'),
        '/splash?from=%2Fhome',
      );
    });
  });

  group('signed out', () {
    test('public routes are allowed', () {
      expect(redirect(const AuthSignedOut(), AppRoutes.login), isNull);
      expect(redirect(const AuthSignedOut(), AppRoutes.signUp), isNull);
    });

    test('protected routes go to login, carrying the target', () {
      expect(
        redirect(const AuthSignedOut(), '/chat/c1'),
        '/login?from=%2Fchat%2Fc1',
      );
    });

    test('splash forwards a carried target to login', () {
      expect(
        redirect(const AuthSignedOut(), '/splash?from=%2Fevents%2Fe1'),
        '/login?from=%2Fevents%2Fe1',
      );
    });
  });

  group('signed in', () {
    test('a ready user leaves auth screens for home', () {
      final status = AuthSignedIn(testUser());
      expect(redirect(status, AppRoutes.login), AppRoutes.home);
      expect(redirect(status, AppRoutes.splash), AppRoutes.home);
      expect(redirect(status, AppRoutes.verifyAlumni), AppRoutes.home);
    });

    test('a ready user resumes the carried target', () {
      expect(
        redirect(AuthSignedIn(testUser()), '/login?from=%2Fposts%2Fp1'),
        '/posts/p1',
      );
    });

    test('a ready user stays on in-app routes', () {
      expect(redirect(AuthSignedIn(testUser()), '/events/e1'), isNull);
    });

    test('`from` cannot point outside the app or back into auth', () {
      final status = AuthSignedIn(testUser());
      expect(
        redirect(status, '/login?from=https%3A%2F%2Fevil.example'),
        AppRoutes.home,
      );
      expect(redirect(status, '/login?from=%2Flogin'), AppRoutes.home);
    });

    test('gates win over any requested route', () {
      expect(
        redirect(AuthSignedIn(testUser(banned: true)), '/home'),
        AppRoutes.banned,
      );
      expect(
        redirect(AuthSignedIn(testUser(emailVerified: false)), '/posts'),
        AppRoutes.verifyEmail,
      );
      expect(
        redirect(AuthSignedIn(testUser(profileCompleted: false)), '/home'),
        AppRoutes.profileSetup,
      );
      expect(
        redirect(AuthSignedIn(testUser(verifiedAlumni: false)), '/home'),
        AppRoutes.verifyAlumni,
      );
      expect(
        redirect(AuthSignedIn(testUser(role: UserRole.admin)), '/home'),
        AppRoutes.adminWeb,
      );
    });

    test('a user already on their gate stays there', () {
      expect(
        redirect(
          AuthSignedIn(testUser(verifiedAlumni: false)),
          AppRoutes.verifyAlumni,
        ),
        isNull,
      );
    });
  });
}
