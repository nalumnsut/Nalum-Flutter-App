import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nalum_app/core/network/app_failure.dart';
import 'package:nalum_app/core/network/failure_mapper.dart';

void main() {
  final request = RequestOptions(path: '/x');

  AppFailure respond(int status, [Object? body]) => mapDioException(
    DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response<Object?>(
        requestOptions: request,
        statusCode: status,
        data: body,
      ),
    ),
  );

  test('connection problems are network failures', () {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      expect(
        mapDioException(DioException(requestOptions: request, type: type)),
        isA<NetworkFailure>(),
      );
    }
  });

  test('status codes map to failures, keeping the server code', () {
    expect(respond(401), isA<UnauthorizedFailure>());
    expect(
      respond(403, {'err': true, 'message': 'x', 'banned': true}),
      isA<ForbiddenFailure>().having((f) => f.code, 'code', 'BANNED'),
    );
    expect(respond(404), isA<NotFoundFailure>());
    expect(respond(426), isA<UpgradeRequiredFailure>());
    expect(respond(429), isA<RateLimitedFailure>());
    expect(respond(503), isA<ServerFailure>());
  });

  test('validation errors carry field problems', () {
    final failure = respond(422, {
      'error': {
        'code': 'VALIDATION_FAILED',
        'message': 'x',
        'fields': {'email': 'invalid'},
      },
    });

    expect(
      failure,
      isA<ValidationFailure>().having((f) => f.fields, 'fields', {
        'email': 'invalid',
      }),
    );
  });
}
