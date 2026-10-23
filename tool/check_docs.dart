import 'dart:io';

/// Keeps the docs trustworthy (AGENTS.md "Conventions" → Docs):
///
/// 1. Every `NAME.md §N.N` reference in code, docs, CI and native config
///    points at a heading that exists (headings look like `## §3 Title`).
/// 2. Every relative Markdown link points at a file that exists.
/// 3. No template placeholders or unowned to-do markers are left behind.
///
/// Run from the repo root: `dart run tool/check_docs.dart`.
void main() {
  final problems = <String>[];
  final headingCache = <String, Set<String>?>{};

  for (final file in _scannedFiles()) {
    final path = file.path.replaceAll(r'\', '/');
    final lines = file.readAsLinesSync();
    final isMarkdown = path.endsWith('.md');
    final isDart = path.endsWith('.dart');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final where = '$path:${i + 1}';

      for (final ref in _sectionRef.allMatches(line)) {
        final doc = ref.group(1)!;
        final section = ref.group(2)!;
        final headings = headingCache.putIfAbsent(doc, () => _headings(doc));
        if (headings == null) {
          problems.add('$where: $doc does not exist');
        } else if (!headings.contains(section)) {
          problems.add('$where: $doc has no section §$section');
        }
      }

      if (isMarkdown) {
        for (final link in _mdLink.allMatches(line)) {
          final target = link.group(1)!;
          if (_isExternal(target)) continue;
          final resolved = File.fromUri(file.uri.resolve(target));
          final dir = Directory.fromUri(file.uri.resolve(target));
          if (!resolved.existsSync() && !dir.existsSync()) {
            problems.add('$where: broken link to $target');
          }
        }
      }

      if (_placeholder.hasMatch(line)) {
        problems.add('$where: template placeholder left in');
      }
      if (isDart && _unownedTodo.hasMatch(line)) {
        problems.add(
          '$where: to-do markers need an owner, e.g. TODO(priya)',
        );
      }
    }
  }

  if (problems.isEmpty) {
    stdout.writeln('Docs OK.');
    return;
  }
  stderr
    ..writeln('Docs problems:')
    ..writeAll(problems.map((p) => '  $p\n'));
  exitCode = 1;
}

/// `ARCHITECTURE.md §4.2`, `docs/AUTH.md §3`. Group 1 is the file, group 2
/// the section number.
final _sectionRef = RegExp(r'(?:docs/)?([A-Z][A-Z0-9_]*\.md) §(\d+(?:\.\d+)*)');
final _heading = RegExp(r'^#{1,6}\s+§(\d+(?:\.\d+)*)\b');
final _mdLink = RegExp(r'\]\(([^)\s#]+)(?:#[^)]*)?\)');

// Built from pieces so this file does not flag itself.
final _placeholder = RegExp(
  '\\[In${'sert'}|lorem ip${'sum'}|FIX${'ME'}',
  caseSensitive: false,
);
final _unownedTodo = RegExp('\\bTO${'DO'}\\b(?!\\()');

bool _isExternal(String target) =>
    target.startsWith('http://') ||
    target.startsWith('https://') ||
    target.startsWith('mailto:');

Set<String>? _headings(String docName) {
  // Root files (AGENTS.md, SETUP.md) win over docs/ files of the same name.
  final file = File(docName).existsSync()
      ? File(docName)
      : File('docs/$docName');
  if (!file.existsSync()) return null;
  return {
    for (final line in file.readAsLinesSync())
      if (_heading.firstMatch(line) case final match?) match.group(1)!,
  };
}

Iterable<File> _scannedFiles() sync* {
  const rootFiles = [
    'AGENTS.md',
    'README.md',
    'SETUP.md',
    'SECURITY.md',
    'apps/mobile/android/app/build.gradle.kts',
    'apps/mobile/android/app/src/main/AndroidManifest.xml',
    'apps/mobile/android/app/src/debug/AndroidManifest.xml',
  ];
  for (final path in rootFiles) {
    final file = File(path);
    if (file.existsSync()) yield file;
  }

  const roots = [
    'docs',
    '.github',
    'tool',
    'apps/mobile/lib',
    'apps/mobile/test',
    'packages',
  ];
  const extensions = ['.md', '.dart', '.yml', '.yaml', '.sh'];
  for (final root in roots) {
    final dir = Directory(root);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File) continue;
      final path = entity.path.replaceAll(r'\', '/');
      if (path.contains('/.dart_tool/') ||
          path.contains('/build/') ||
          path.contains('/l10n/generated/') ||
          path.endsWith('.g.dart') ||
          path.endsWith('.freezed.dart') ||
          path.endsWith('tool/check_docs.dart')) {
        continue;
      }
      if (extensions.any(path.endsWith)) yield entity;
    }
  }
}
