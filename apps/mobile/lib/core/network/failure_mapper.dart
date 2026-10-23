import 'package:dio/dio.dart';
import 'package:nalum_api/nalum_api.dart';
import 'package:nalum_app/core/network/app_failure.dart';

/// Turns a [DioException] into an [AppFailure] (docs/ARCHITECTURE.md §5).
AppFailure mapDioException(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
    case DioExceptionType.badCertificate:
      return const NetworkFailure();
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return UnexpectedFailure(exception.error);
    case DioExceptionType.badResponse:
      return _fromResponse(exception.response);
  }
}

AppFailure _fromResponse(Response<Object?>? response) {
  final status = response?.statusCode ?? 0;
  final error = ApiError.tryParse(response?.data);
  final code = error?.code ?? ApiErrorCode.unknown;

  return switch (status) {
    401 => UnauthorizedFailure(code),
    // Legacy trap: routes guarded by authenticateJWT answer an expired token
    // with 403, so no refresh happens there (docs/API.md §5.1). Do not
    // "fix" that here by refreshing on 403: banned users also get 403.
    403 => ForbiddenFailure(code),
    404 => const NotFoundFailure(),
    400 || 422 => ValidationFailure(code, error?.fields ?? const {}),
    426 => const UpgradeRequiredFailure(),
    429 => const RateLimitedFailure(),
    >= 500 => ServerFailure(status),
    _ => UnexpectedFailure('HTTP $status'),
  };
}
