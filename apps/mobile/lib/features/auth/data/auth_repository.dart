import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nalum_api/nalum_api.dart';
import 'package:nalum_app/core/network/app_failure.dart';
import 'package:nalum_app/core/network/dio_provider.dart';
import 'package:nalum_app/core/network/failure_mapper.dart';
import 'package:nalum_app/features/auth/domain/auth_status.dart';
import 'package:nalum_app/features/auth/domain/session_user.dart';

/// Every method throws [AppFailure] on error, never a raw DioException.
abstract interface class AuthRepository {
  Future<AuthSession> signIn({required String email, required String password});
  Future<AuthSession> refresh(String refreshToken);
  Future<void> signOut(String? refreshToken);
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => HttpAuthRepository(ref.watch(authDioProvider)),
);

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(this._dio);

  final Dio _dio;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) {
    return _session(
      () => _dio.post<Object?>(
        ApiPaths.signIn,
        data: {'email': email, 'password': password},
      ),
    );
  }

  @override
  Future<AuthSession> refresh(String refreshToken) {
    return _session(
      () => _dio.post<Object?>(
        ApiPaths.refresh,
        data: {'refresh_token': refreshToken},
      ),
    );
  }

  @override
  Future<void> signOut(String? refreshToken) async {
    try {
      await _dio.post<Object?>(
        ApiPaths.logout,
        data: {'refresh_token': ?refreshToken},
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AuthSession> _session(
    Future<Response<Object?>> Function() request,
  ) async {
    final Response<Object?> response;
    try {
      response = await request();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
    return _parseSession(response.data);
  }

  /// Both the legacy and the v1 response wrap the session in `data`
  /// (docs/API.md §3.1).
  AuthSession _parseSession(Object? body) {
    try {
      final data =
          (body! as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(data);
      final user = UserDto.fromJson(data['user'] as Map<String, dynamic>);
      return AuthSession(
        tokens: SessionTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        ),
        user: _toSessionUser(user),
      );
    } on Object catch (e) {
      // Malformed response: a contract bug, not a user error.
      throw UnexpectedFailure(e);
    }
  }

  SessionUser _toSessionUser(UserDto dto) => SessionUser(
    id: dto.id,
    name: dto.name,
    role: UserRole.parse(dto.role),
    emailVerified: dto.emailVerified,
    profileCompleted: dto.profileCompleted,
    verifiedAlumni: dto.verifiedAlumni,
    hasPassword: dto.hasPassword,
    banned: dto.banned,
    verificationExpired: dto.verificationExpired,
  );
}
