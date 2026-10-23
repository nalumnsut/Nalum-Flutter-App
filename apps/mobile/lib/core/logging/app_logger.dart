import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// The only logging entry point. Debug builds only.
///
/// Never pass tokens, passwords, OTPs, emails, message bodies or full
/// response bodies (AGENTS.md "Hard rules" → Privacy). Log ids and codes.
abstract final class AppLogger {
  static void info(String message) {
    if (kDebugMode) developer.log(message, name: 'nalum');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'nalum',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
    // Crashlytics hook goes here once Firebase is set up
    // (docs/NOTIFICATIONS.md §2, docs/RELEASING.md §6).
  }
}
