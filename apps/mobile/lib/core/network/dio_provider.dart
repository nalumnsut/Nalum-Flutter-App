import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nalum_app/core/config/app_env.dart';
import 'package:nalum_app/core/logging/app_logger.dart';
import 'package:nalum_app/core/network/auth_interceptor.dart';

final accessTokenHolderProvider = Provider<AccessTokenHolder>(
  (ref) => AccessTokenHolder(),
);

/// Overridden in `appOverrides()` with the auth controller.
final sessionRefresherProvider = Provider<SessionRefresher>(
  (ref) =>
      throw UnimplementedError('sessionRefresherProvider must be overridden'),
);

/// For auth endpoints only: no bearer token, no refresh-on-401.
final authDioProvider = Provider<Dio>((ref) {
  return _createDio(ref.watch(appEnvProvider));
});

/// For every other endpoint.
final apiDioProvider = Provider<Dio>((ref) {
  final dio = _createDio(ref.watch(appEnvProvider));
  dio.interceptors.insert(
    0,
    AuthInterceptor(
      dio: dio,
      tokens: ref.watch(accessTokenHolderProvider),
      refresher: ref.watch(sessionRefresherProvider),
    ),
  );
  return dio;
});

Dio _createDio(AppEnv env) {
  final dio = Dio(
    BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        // Tells the backend to return the refresh token in the body instead
        // of a cookie (docs/AUTH.md §3.2).
        'X-Client': 'mobile',
      },
    ),
  );
  if (kDebugMode) dio.interceptors.add(_SafeLogInterceptor());
  return dio;
}

/// Logs method, path and status only. dio's built-in LogInterceptor prints
/// headers and bodies, which would leak tokens and personal data.
class _SafeLogInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    AppLogger.info(
      '${request.method} ${request.path} → ${response.statusCode}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final request = err.requestOptions;
    AppLogger.info(
      '${request.method} ${request.path} ✕ ${err.response?.statusCode ?? err.type.name}',
    );
    handler.next(err);
  }
}
