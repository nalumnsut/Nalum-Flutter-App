import 'package:dio/dio.dart';

/// Holds the short-lived access token in memory only. It is never persisted
/// (docs/AUTH.md §3.1).
class AccessTokenHolder {
  String? token;
}

/// Implemented by the auth feature; core only knows this interface, so the
/// dependency points from features to core (docs/ARCHITECTURE.md §4.2).
// One method on purpose: the auth feature implements it on its controller.
// ignore: one_member_abstracts
abstract interface class SessionRefresher {
  /// Returns a new access token, or null if the session is gone. The
  /// implementation decides whether to sign the user out.
  Future<String?> refreshAccessToken();
}

/// Marks a request that must not carry or refresh the access token.
const skipAuthExtra = 'skipAuth';
const _retriedExtra = 'authRetried';

/// Attaches the bearer token and, on 401, refreshes once and retries.
///
/// Concurrent 401s share one refresh: without that, N parallel requests would
/// rotate the refresh token N times and the server's reuse detection would
/// revoke the session (docs/AUTH.md §3.3).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required AccessTokenHolder tokens,
    required SessionRefresher refresher,
  }) : _dio = dio,
       _tokens = tokens,
       _refresher = refresher;

  final Dio _dio;
  final AccessTokenHolder _tokens;
  final SessionRefresher _refresher;
  Future<String?>? _inflightRefresh;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokens.token;
    // A retry already carries the token the refresh returned; overwriting it
    // here would resend whatever the holder had when the 401 happened.
    final isRetry = options.extra[_retriedExtra] == true;
    if (token != null && !isRetry && options.extra[skipAuthExtra] != true) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final unauthorized = err.response?.statusCode == 401;
    if (!unauthorized ||
        options.extra[skipAuthExtra] == true ||
        options.extra[_retriedExtra] == true) {
      return handler.next(err);
    }

    final newToken = await (_inflightRefresh ??= _refresher
        .refreshAccessToken()
        .whenComplete(() => _inflightRefresh = null));
    if (newToken == null) return handler.next(err);

    options
      ..headers['Authorization'] = 'Bearer $newToken'
      ..extra[_retriedExtra] = true;
    try {
      handler.resolve(await _dio.fetch<Object?>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
