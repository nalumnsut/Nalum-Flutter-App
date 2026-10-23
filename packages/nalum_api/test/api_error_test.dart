import 'package:nalum_api/nalum_api.dart';
import 'package:test/test.dart';

void main() {
  group('ApiError.tryParse', () {
    test('parses the v1 envelope with fields', () {
      final error = ApiError.tryParse({
        'error': {
          'code': 'VALIDATION_FAILED',
          'message': 'Bad input',
          'fields': {'email': 'invalid', 'ignored': 3},
        },
      });

      expect(error?.code, ApiErrorCode.validationFailed);
      expect(error?.fields, {'email': 'invalid'});
    });

    test('maps the legacy banned flag', () {
      final error = ApiError.tryParse({
        'err': true,
        'code': 403,
        'message': 'Your account has been permanently banned.',
        'banned': true,
      });

      expect(error?.code, ApiErrorCode.banned);
    });

    test('maps the legacy verification_expired flag', () {
      final error = ApiError.tryParse({
        'err': true,
        'message': 'expired',
        'verification_expired': true,
      });

      expect(error?.code, ApiErrorCode.verificationExpired);
    });

    test('accepts {error: true} and {success: false} as unknown errors', () {
      expect(
        ApiError.tryParse({'error': true, 'message': 'x'})?.code,
        ApiErrorCode.unknown,
      );
      expect(
        ApiError.tryParse({'success': false, 'message': 'x'})?.code,
        ApiErrorCode.unknown,
      );
    });

    test('returns null for success bodies and non-maps', () {
      expect(
        ApiError.tryParse({'error': false, 'data': <String, Object>{}}),
        isNull,
      );
      expect(ApiError.tryParse('Internal server error.'), isNull);
      expect(ApiError.tryParse(null), isNull);
    });

    test('toString does not leak the server message', () {
      const error = ApiError(code: 'X', message: 'secret@example.com');
      expect(error.toString(), isNot(contains('secret')));
    });
  });
}
