/// NALUM backend contract: endpoint paths, the error envelope and DTOs.
///
/// Pure Dart (no Flutter). The shapes follow the proposed v1 contract in
/// docs/API.md §3, with parsers that also accept today's legacy responses
/// (docs/API.md §5) while the backend is being rewritten.
library;

export 'src/api_paths.dart';
export 'src/dto/auth_tokens.dart';
export 'src/dto/user_dto.dart';
export 'src/envelope/api_error.dart';
export 'src/envelope/api_error_code.dart';
