import 'package:nalum_api/nalum_api.dart';
import 'package:test/test.dart';

void main() {
  test('UserDto reads the mixed-case legacy user object', () {
    // Shape copied from today's sign-in response (routes/auth/signIn.js),
    // with made-up values.
    final user = UserDto.fromJson({
      'id': '65f000000000000000000001',
      'name': 'Test Alumnus',
      'email': 'alumnus@example.com',
      'role': 'alumni',
      'email_verified': true,
      'profileCompleted': true,
      'verified_alumni': false,
      'hasPassword': true,
    });

    expect(user.emailVerified, isTrue);
    expect(user.profileCompleted, isTrue);
    expect(user.verifiedAlumni, isFalse);
    expect(user.banned, isFalse);
  });

  test(
    'AuthTokens tolerates a missing refresh token (cookie-only backend)',
    () {
      final tokens = AuthTokens.fromJson({'access_token': 'a.b.c'});

      expect(tokens.accessToken, 'a.b.c');
      expect(tokens.refreshToken, isNull);
    },
  );
}
