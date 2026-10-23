// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_tokens.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_AuthTokens',
  json,
  ($checkedConvert) {
    final val = _AuthTokens(
      accessToken: $checkedConvert('access_token', (v) => v as String),
      refreshToken: $checkedConvert('refresh_token', (v) => v as String?),
      expiresIn: $checkedConvert('expires_in', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'accessToken': 'access_token',
    'refreshToken': 'refresh_token',
    'expiresIn': 'expires_in',
  },
);

Map<String, dynamic> _$AuthTokensToJson(_AuthTokens instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'expires_in': instance.expiresIn,
    };
