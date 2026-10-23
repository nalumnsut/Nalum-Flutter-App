import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens.freezed.dart';
part 'auth_tokens.g.dart';

/// Tokens returned by sign-in and refresh.
///
/// [refreshToken] is null on today's backend, which only sets it as an
/// httpOnly cookie. Mobile needs it in the body (docs/AUTH.md §3.2).
@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    String? refreshToken,
    int? expiresIn,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}
