---
name: tekartik-app-io-zip-setup
description: >-
  Use when a Dart io program (command line tool, build script, server, test)
  must create or extract a .zip archive of a folder with tekartik_app_io_zip:
  the two helpers zip(directoryPath, dst:) and unzip(zipFilePath, dst:) from
  package:tekartik_app_io_zip/zip.dart, their default destination rules,
  archive/ZipFileEncoder/ZipDecoder underneath, executable (unix) permission
  restore on extract, and when to drop down to package:archive instead.
---

# Zip and unzip folders on io (tekartik_app_io_zip)

`tekartik_app_io_zip` wraps `package:archive` in two `dart:io` helpers: `zip`
packs a directory into a `.zip` file, `unzip` extracts a `.zip` file into a
directory and restores the unix executable bit.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_io_zip:
      git:
        url: https://github.com/tekartik/app_io_utils.dart
        path: packages/app_zip
      version: '>=1.0.0'
  ```
  It brings `archive`, `path` and `tekartik_io_utils`.
* Import `package:tekartik_app_io_zip/zip.dart`. It exports exactly two
  top level functions and nothing else, so `dart:io` (`File`, `Directory`) and
  `package:path/path.dart` (`join`) still need their own imports:
  - `Future<void> zip(String directoryPath, {String? dst})`
  - `Future<void> unzip(String zipFilePath, {String? dst})`
* `zip(directoryPath)` archives the *contents* of the directory: entries are
  stored relative to `directoryPath`, the folder name itself is not a prefix
  inside the archive. `dst` is the target `.zip` file path; its parent
  directory is created if missing. Without `dst` the archive is written next
  to the source folder, as `<dirname>/<basenameWithoutExtension>.zip` (so
  `zip('build/web')` writes `build/web.zip`; beware a folder name containing a
  dot, the part after it is dropped).
* `unzip(zipFilePath)` extracts into `dst`, creating sub directories as
  needed. Without `dst` it extracts next to the archive, into
  `<dirname>/<basenameWithoutExtension>` (so `unzip('build/web.zip')` fills
  `build/web`). Existing files are overwritten and nothing else is removed:
  the destination is not cleaned first, so delete or re-create it yourself
  when you need an exact copy.
* Extraction restores the executable bit: when the platform supports file
  permissions (`supportsFilePermission`, posix only) and the zip entry carries
  unix exec bits, the extracted file is made executable. The reverse is not
  guaranteed: `ZipFileEncoder` does not always record permissions, so do not
  rely on `zip` + `unzip` to round trip a `+x` flag; re-apply it after
  extraction if it matters.
* Both functions are `Future<void>`: `await` them. `unzip` reads the whole
  archive into memory (`File.readAsBytes` then `ZipDecoder`), so avoid it for
  very large archives and use `package:archive` streaming APIs
  (`InputFileStream`, `extractArchiveToDisk`) there instead.
* io only (`dart:io`), and zip only: no tar, no gzip, no password protected
  archives, no in-memory archive, no per-entry filter. Use `package:archive`
  directly (`ZipFileEncoder().addFile`, `ZipDecoder`) when you need to pick
  entries, read a zip without writing files, or build an archive from bytes.
* The top level name `zip` is short and collides easily with a local variable
  or with a `zip` from another package: import with `show zip, unzip` or with
  a prefix (`as zip_utils`) inside a file that has its own `zip` symbol.
* Testing: zip/unzip under `.dart_tool/<package>/test/...` rather than the
  system temp directory, delete the folder in `setUp`, and compare the
  extracted file contents; the package's own tests follow that pattern.

## Examples

### Zip a folder, then extract it

```dart
import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_app_io_zip/zip.dart';

Future<void> main() async {
  var workDir = join('.dart_tool', 'my_tool', 'zip');
  var zipFilePath = join(workDir, 'lib_files.zip');

  try {
    await Directory(workDir).delete(recursive: true);
  } catch (_) {}

  // Archives the content of lib/ (no 'lib/' prefix inside the archive)
  await zip('lib', dst: zipFilePath);
  print('$zipFilePath: ${File(zipFilePath).statSync().size} bytes');

  await unzip(zipFilePath, dst: join(workDir, 'extracted'));
}
```

### Default destinations

```dart
import 'package:tekartik_app_io_zip/zip.dart';

Future<void> main() async {
  // No dst: writes build/web.zip next to the folder
  await zip('build/web');

  // No dst: extracts into build/web
  await unzip('build/web.zip');
}
```

### Build script packaging an output folder

```dart
import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_app_io_zip/zip.dart';

Future<String> packageBuild(String buildDir, {required String name}) async {
  var stamp = DateTime.now().toIso8601String().substring(0, 10);
  var dst = join('dist', '$name-$stamp.zip');
  // dist/ is created by zip() if missing
  await zip(buildDir, dst: dst);
  return dst;
}

Future<void> main(List<String> args) async {
  var buildDir = args.isEmpty ? join('build', 'web') : args.first;
  if (!Directory(buildDir).existsSync()) {
    stderr.writeln('missing build directory $buildDir');
    exitCode = 1;
    return;
  }
  var dst = await packageBuild(buildDir, name: 'my_app');
  stdout.writeln('packaged $buildDir into $dst');
}
```

### Round trip test

```dart
import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_app_io_zip/zip.dart';
import 'package:test/test.dart';

void main() {
  test('zip/unzip', () async {
    var dir = join('.dart_tool', 'my_tool', 'test', 'zip_unzip');
    try {
      await Directory(dir).delete(recursive: true);
    } catch (_) {}

    var srcDir = join(dir, 'src');
    await Directory(srcDir).create(recursive: true);
    await File(join(srcDir, 'test.txt')).writeAsString('test');

    // No dst: creates <dir>/src.zip
    await zip(srcDir);
    var dstDir = join(dir, 'dst');
    await unzip('$srcDir.zip', dst: dstDir);

    expect(await File(join(dstDir, 'test.txt')).readAsString(), 'test');
  });
}
```

## Common mistakes

* Expecting the source folder name inside the archive: `zip('src')` stores
  `test.txt`, not `src/test.txt`.
* Expecting `unzip` to clean the destination: it only overwrites the entries
  present in the archive.
* Passing a `.zip` file (instead of a directory) to `zip`, or a directory
  (instead of a `.zip` file) to `unzip`.
* Relying on the executable bit surviving `zip` then `unzip`.
* Unzipping a huge archive with this helper: it is fully loaded in memory.
* Forgetting `await`: both helpers return a `Future` and do real file i/o.
