// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserDto {

 String get id; String get name; String get email; String get role; bool get emailVerified;@JsonKey(name: 'profileCompleted') bool get profileCompleted; bool get verifiedAlumni;@JsonKey(name: 'hasPassword') bool get hasPassword; bool get banned; bool get verificationExpired;
/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDtoCopyWith<UserDto> get copyWith => _$UserDtoCopyWithImpl<UserDto>(this as UserDto, _$identity);

  /// Serializes this UserDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.profileCompleted, profileCompleted) || other.profileCompleted == profileCompleted)&&(identical(other.verifiedAlumni, verifiedAlumni) || other.verifiedAlumni == verifiedAlumni)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&(identical(other.banned, banned) || other.banned == banned)&&(identical(other.verificationExpired, verificationExpired) || other.verificationExpired == verificationExpired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,role,emailVerified,profileCompleted,verifiedAlumni,hasPassword,banned,verificationExpired);

@override
String toString() {
  return 'UserDto(id: $id, name: $name, email: $email, role: $role, emailVerified: $emailVerified, profileCompleted: $profileCompleted, verifiedAlumni: $verifiedAlumni, hasPassword: $hasPassword, banned: $banned, verificationExpired: $verificationExpired)';
}


}

/// @nodoc
abstract mixin class $UserDtoCopyWith<$Res>  {
  factory $UserDtoCopyWith(UserDto value, $Res Function(UserDto) _then) = _$UserDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String role, bool emailVerified,@JsonKey(name: 'profileCompleted') bool profileCompleted, bool verifiedAlumni,@JsonKey(name: 'hasPassword') bool hasPassword, bool banned, bool verificationExpired
});




}
/// @nodoc
class _$UserDtoCopyWithImpl<$Res>
    implements $UserDtoCopyWith<$Res> {
  _$UserDtoCopyWithImpl(this._self, this._then);

  final UserDto _self;
  final $Res Function(UserDto) _then;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? role = null,Object? emailVerified = null,Object? profileCompleted = null,Object? verifiedAlumni = null,Object? hasPassword = null,Object? banned = null,Object? verificationExpired = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,profileCompleted: null == profileCompleted ? _self.profileCompleted : profileCompleted // ignore: cast_nullable_to_non_nullable
as bool,verifiedAlumni: null == verifiedAlumni ? _self.verifiedAlumni : verifiedAlumni // ignore: cast_nullable_to_non_nullable
as bool,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,banned: null == banned ? _self.banned : banned // ignore: cast_nullable_to_non_nullable
as bool,verificationExpired: null == verificationExpired ? _self.verificationExpired : verificationExpired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserDto].
extension UserDtoPatterns on UserDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDto value)  $default,){
final _that = this;
switch (_that) {
case _UserDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String role,  bool emailVerified, @JsonKey(name: 'profileCompleted')  bool profileCompleted,  bool verifiedAlumni, @JsonKey(name: 'hasPassword')  bool hasPassword,  bool banned,  bool verificationExpired)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role,_that.emailVerified,_that.profileCompleted,_that.verifiedAlumni,_that.hasPassword,_that.banned,_that.verificationExpired);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String role,  bool emailVerified, @JsonKey(name: 'profileCompleted')  bool profileCompleted,  bool verifiedAlumni, @JsonKey(name: 'hasPassword')  bool hasPassword,  bool banned,  bool verificationExpired)  $default,) {final _that = this;
switch (_that) {
case _UserDto():
return $default(_that.id,_that.name,_that.email,_that.role,_that.emailVerified,_that.profileCompleted,_that.verifiedAlumni,_that.hasPassword,_that.banned,_that.verificationExpired);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String role,  bool emailVerified, @JsonKey(name: 'profileCompleted')  bool profileCompleted,  bool verifiedAlumni, @JsonKey(name: 'hasPassword')  bool hasPassword,  bool banned,  bool verificationExpired)?  $default,) {final _that = this;
switch (_that) {
case _UserDto() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role,_that.emailVerified,_that.profileCompleted,_that.verifiedAlumni,_that.hasPassword,_that.banned,_that.verificationExpired);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDto implements UserDto {
  const _UserDto({required this.id, required this.name, required this.email, required this.role, this.emailVerified = false, @JsonKey(name: 'profileCompleted') this.profileCompleted = false, this.verifiedAlumni = false, @JsonKey(name: 'hasPassword') this.hasPassword = false, this.banned = false, this.verificationExpired = false});
  factory _UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
@override final  String role;
@override@JsonKey() final  bool emailVerified;
@override@JsonKey(name: 'profileCompleted') final  bool profileCompleted;
@override@JsonKey() final  bool verifiedAlumni;
@override@JsonKey(name: 'hasPassword') final  bool hasPassword;
@override@JsonKey() final  bool banned;
@override@JsonKey() final  bool verificationExpired;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDtoCopyWith<_UserDto> get copyWith => __$UserDtoCopyWithImpl<_UserDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.profileCompleted, profileCompleted) || other.profileCompleted == profileCompleted)&&(identical(other.verifiedAlumni, verifiedAlumni) || other.verifiedAlumni == verifiedAlumni)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&(identical(other.banned, banned) || other.banned == banned)&&(identical(other.verificationExpired, verificationExpired) || other.verificationExpired == verificationExpired));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,role,emailVerified,profileCompleted,verifiedAlumni,hasPassword,banned,verificationExpired);

@override
String toString() {
  return 'UserDto(id: $id, name: $name, email: $email, role: $role, emailVerified: $emailVerified, profileCompleted: $profileCompleted, verifiedAlumni: $verifiedAlumni, hasPassword: $hasPassword, banned: $banned, verificationExpired: $verificationExpired)';
}


}

/// @nodoc
abstract mixin class _$UserDtoCopyWith<$Res> implements $UserDtoCopyWith<$Res> {
  factory _$UserDtoCopyWith(_UserDto value, $Res Function(_UserDto) _then) = __$UserDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String role, bool emailVerified,@JsonKey(name: 'profileCompleted') bool profileCompleted, bool verifiedAlumni,@JsonKey(name: 'hasPassword') bool hasPassword, bool banned, bool verificationExpired
});




}
/// @nodoc
class __$UserDtoCopyWithImpl<$Res>
    implements _$UserDtoCopyWith<$Res> {
  __$UserDtoCopyWithImpl(this._self, this._then);

  final _UserDto _self;
  final $Res Function(_UserDto) _then;

/// Create a copy of UserDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? role = null,Object? emailVerified = null,Object? profileCompleted = null,Object? verifiedAlumni = null,Object? hasPassword = null,Object? banned = null,Object? verificationExpired = null,}) {
  return _then(_UserDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,profileCompleted: null == profileCompleted ? _self.profileCompleted : profileCompleted // ignore: cast_nullable_to_non_nullable
as bool,verifiedAlumni: null == verifiedAlumni ? _self.verifiedAlumni : verifiedAlumni // ignore: cast_nullable_to_non_nullable
as bool,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,banned: null == banned ? _self.banned : banned // ignore: cast_nullable_to_non_nullable
as bool,verificationExpired: null == verificationExpired ? _self.verificationExpired : verificationExpired // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
