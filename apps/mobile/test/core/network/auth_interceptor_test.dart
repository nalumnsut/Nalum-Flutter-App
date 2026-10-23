import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nalum_app/core/network/auth_interceptor.dart';

/// Answers 401 unless the request carries the current valid token.
class _FakeAdapter implements HttpClientAdapter {
  String validToken = 'new';
  final List<String?> seenAuthHeaders = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final auth = options.headers['Authorization'] as String?;
    seenAuthHeaders.add(auth);
    final ok = auth == 'Bearer $validToken';
    return ResponseBody.fromString(
      jsonEncode({'ok': ok}),
      ok ? 200 : 401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _CountingRefresher implements SessionRefresher {
  _CountingRefresher(this.result);

  final String? result;
  final gate = Completer<void>();
  int calls = 0;

  @override
  Future<String?> refreshAccessToken() async {
    calls++;
    await gate.future;
    return result;
  }
}

void main() {
  late Dio dio;
  late _FakeAdapter adapter;
  late AccessTokenHolder tokens;

  void setUpDio(SessionRefresher refresher) {
    adapter = _FakeAdapter();
    tokens = AccessTokenHolder()..token = 'old';
    dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(
      AuthInterceptor(dio: dio, tokens: tokens, refresher: refresher),
    );
  }

  test('attaches the bearer token', () async {
    setUpDio(_CountingRefresher('new'));
    tokens.token = 'new';

    final response = await dio.get<Object?>('/me');

    expect(response.statusCode, 200);
    expect(adapter.seenAuthHeaders.single, 'Bearer new');
  });

  test('concurrent 401s share one refresh, then all retry', () async {
    final refresher = _CountingRefresher('new');
    setUpDio(refresher);

    final requests = [
      dio.get<Object?>('/a'),
      dio.get<Object?>('/b'),
      dio.get<Object?>('/c'),
    ];
    await pumpEventQueue();
    refresher.gate.complete();
    final responses = await Future.wait(requests);

    expect(refresher.calls, 1);
    expect(responses.map((r) => r.statusCode), everyElement(200));
  });

  test('a failed refresh passes the original 401 through', () async {
    final refresher = _CountingRefresher(null)..gate.complete();
    setUpDio(refresher);

    await expectLater(
      dio.get<Object?>('/a'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
  });

  test('requests marked skipAuth never refresh', () async {
    final refresher = _CountingRefresher('new')..gate.complete();
    setUpDio(refresher);

    await expectLater(
      dio.get<Object?>('/a', options: Options(extra: {skipAuthExtra: true})),
      throwsA(isA<DioException>()),
    );
    expect(refresher.calls, 0);
    expect(adapter.seenAuthHeaders.single, isNull);
  });
}
