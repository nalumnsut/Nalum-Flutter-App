// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_UserDto',
  json,
  ($checkedConvert) {
    final val = _UserDto(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      email: $checkedConvert('email', (v) => v as String),
      role: $checkedConvert('role', (v) => v as String),
      emailVerified: $checkedConvert(
        'email_verified',
        (v) => v as bool? ?? false,
      ),
      profileCompleted: $checkedConvert(
        'profileCompleted',
        (v) => v as bool? ?? false,
      ),
      verifiedAlumni: $checkedConvert(
        'verified_alumni',
        (v) => v as bool? ?? false,
      ),
      hasPassword: $checkedConvert('hasPassword', (v) => v as bool? ?? false),
      banned: $checkedConvert('banned', (v) => v as bool? ?? false),
      verificationExpired: $checkedConvert(
        'verification_expired',
        (v) => v as bool? ?? false,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'emailVerified': 'email_verified',
    'verifiedAlumni': 'verified_alumni',
    'verificationExpired': 'verification_expired',
  },
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
  'email_verified': instance.emailVerified,
  'profileCompleted': instance.profileCompleted,
  'verified_alumni': instance.verifiedAlumni,
  'hasPassword': instance.hasPassword,
  'banned': instance.banned,
  'verification_expired': instance.verificationExpired,
};
