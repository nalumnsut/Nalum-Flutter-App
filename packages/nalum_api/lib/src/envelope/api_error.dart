import 'package:nalum_api/src/envelope/api_error_code.dart';

/// A parsed error response.
///
/// The target shape is `{ "error": { "code", "message", "fields"? } }`
/// (docs/API.md §3.2). Today's backend returns several other shapes
/// (docs/API.md §5.1), so [tryParse] accepts those too and infers a code only
/// where the legacy response carries an explicit flag.
class ApiError {
  const ApiError({
    required this.code,
    required this.message,
    this.fields = const {},
  });

  final String code;

  /// Server text. Never shown to users in release builds; the UI picks
  /// localized text from [code] (AGENTS.md "Hard rules" → Privacy).
  final String message;

  /// Field name → problem, for validation errors.
  final Map<String, String> fields;

  /// Returns null when [body] does not look like an error.
  static ApiError? tryParse(Object? body) {
    if (body is! Map) return null;
    final map = body.cast<Object?, Object?>();

    // v1 envelope.
    final error = map['error'];
    if (error is Map) {
      final e = error.cast<Object?, Object?>();
      return ApiError(
        code: _string(e['code']) ?? ApiErrorCode.unknown,
        message: _string(e['message']) ?? '',
        fields: _fields(e['fields']),
      );
    }

    // Legacy shapes: {err: true, code: 401, message}, {error: true, message},
    // {success: false, message}. Only flags the backend sends today are
    // mapped; guessing from message text would break silently on rewording.
    final isLegacyError =
        map['err'] == true || error == true || map['success'] == false;
    if (!isLegacyError) return null;

    final String code;
    if (map['banned'] == true) {
      code = ApiErrorCode.banned;
    } else if (map['verification_expired'] == true) {
      code = ApiErrorCode.verificationExpired;
    } else {
      code = ApiErrorCode.unknown;
    }
    return ApiError(code: code, message: _string(map['message']) ?? '');
  }

  static String? _string(Object? value) => value is String ? value : null;

  static Map<String, String> _fields(Object? value) {
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries)
        if (entry.key is String && entry.value is String)
          entry.key as String: entry.value as String,
    };
  }

  // Deliberately omits [message]: errors end up in logs and crash reports.
  @override
  String toString() => 'ApiError($code)';
}
