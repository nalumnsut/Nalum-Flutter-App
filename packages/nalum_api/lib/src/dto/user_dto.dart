import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// The `user` object embedded in sign-in and refresh responses.
///
/// Casing is mixed on today's backend (`email_verified` but
/// `profileCompleted`), so the camelCase fields carry an explicit key. The v1
/// contract makes everything snake_case (docs/API.md §5.2).
@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String name,
    required String email,
    required String role,
    @Default(false) bool emailVerified,
    @JsonKey(name: 'profileCompleted') @Default(false) bool profileCompleted,
    @Default(false) bool verifiedAlumni,
    @JsonKey(name: 'hasPassword') @Default(false) bool hasPassword,
    @Default(false) bool banned,
    @Default(false) bool verificationExpired,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}
