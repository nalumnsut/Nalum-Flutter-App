import 'dart:io';

/// Enforces the import rules in docs/ARCHITECTURE.md §4. The analyzer cannot
/// express "this folder may not import that folder", so this script does.
///
/// Run from the repo root: `dart run tool/check_architecture.dart`.
void main() {
  final violations = <String>[
    for (final file in _dartFiles('apps/mobile/lib')) ..._checkApp(file),
    for (final file in _dartFiles('packages/nalum_api/lib'))
      ..._checkPackage(file, const [
        'package:flutter/',
        'package:dio/',
      ], '§4.6'),
    for (final file in _dartFiles('packages/nalum_ui/lib'))
      ..._checkPackage(file, const [
        'package:nalum_app/',
        'package:nalum_api/',
        'package:dio/',
        'package:flutter_riverpod/',
      ], '§4.6'),
  ];

  if (violations.isEmpty) {
    stdout.writeln('Architecture boundaries OK.');
    return;
  }
  stderr
    ..writeln('Architecture violations (docs/ARCHITECTURE.md §4):')
    ..writeAll(violations.map((v) => '  $v\n'));
  exitCode = 1;
}

const _appPrefix = 'apps/mobile/lib/';
const _featureImport = 'package:nalum_app/features/';

/// Imports a domain file may use: plain Dart, no Flutter, no I/O, no
/// packages beyond meta/collection, and only other domain code (§4.3).
bool _allowedInDomain(String uri) {
  const allowedDart = {
    'dart:async',
    'dart:collection',
    'dart:convert',
    'dart:core',
    'dart:math',
    'dart:typed_data',
  };
  if (uri.startsWith('dart:')) return allowedDart.contains(uri);
  if (uri.startsWith('package:meta/') ||
      uri.startsWith('package:collection/')) {
    return true;
  }
  return uri.startsWith(_featureImport) && _layerOf(uri) == 'domain';
}

Iterable<String> _checkApp(_DartFile file) sync* {
  final relative = file.path.substring(_appPrefix.length);
  final parts = relative.split('/');
  final isCore = parts.first == 'core';
  final feature = parts.first == 'features' && parts.length > 2
      ? parts[1]
      : null;
  final layer = feature != null && parts.length > 3 ? parts[2] : null;

  for (final import in file.imports) {
    final uri = import.uri;
    String fail(String rule, String why) =>
        '${file.path}:${import.line} imports $uri — $why (§$rule)';

    if (isCore &&
        (uri.startsWith(_featureImport) ||
            uri.startsWith('package:nalum_app/app/'))) {
      yield fail('4.2', 'core must not depend on features or app');
    }
    if (feature == null) continue;

    if (uri.startsWith('package:nalum_app/app/')) {
      yield fail('4.2', 'features must not depend on the app layer');
    }
    if (layer == 'domain' && !_allowedInDomain(uri)) {
      yield fail('4.3', 'domain code must stay pure Dart');
    }
    if (layer == 'presentation' &&
        (uri.startsWith('package:dio/') ||
            uri.startsWith('package:nalum_api/') ||
            (uri.startsWith(_featureImport) && _layerOf(uri) == 'data'))) {
      yield fail('4.4', 'screens go through application providers, not data');
    }
    if (uri.startsWith(_featureImport)) {
      final other = uri.substring(_featureImport.length).split('/').first;
      final otherLayer = _layerOf(uri);
      if (other != feature &&
          otherLayer != 'domain' &&
          otherLayer != 'application') {
        yield fail(
          '4.5',
          "only another feature's domain/application is public",
        );
      }
    }
  }
}

Iterable<String> _checkPackage(
  _DartFile file,
  List<String> forbidden,
  String rule,
) sync* {
  for (final import in file.imports) {
    if (forbidden.any(import.uri.startsWith)) {
      yield '${file.path}:${import.line} imports ${import.uri} — '
          'not allowed in this package ($rule)';
    }
  }
}

String? _layerOf(String featureUri) {
  final parts = featureUri.substring(_featureImport.length).split('/');
  return parts.length > 2 ? parts[1] : null;
}

class _Import {
  const _Import(this.uri, this.line);
  final String uri;
  final int line;
}

class _DartFile {
  _DartFile(this.path, this.imports);
  final String path;
  final List<_Import> imports;
}

final _directive = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');

Iterable<_DartFile> _dartFiles(String root) sync* {
  final dir = Directory(root);
  if (!dir.existsSync()) return;
  final files =
      dir
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.dart') &&
                !f.path.endsWith('.g.dart') &&
                !f.path.endsWith('.freezed.dart'),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final path = file.path.replaceAll(r'\', '/');
    final lines = file.readAsLinesSync();
    final imports = <_Import>[];
    for (var i = 0; i < lines.length; i++) {
      final match = _directive.firstMatch(lines[i]);
      if (match != null) imports.add(_Import(match.group(1)!, i + 1));
    }
    yield _DartFile(path, imports);
  }
}
