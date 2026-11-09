# tekartik_app_io_zip

Zip a folder into a `.zip` file and extract a `.zip` file into a folder, for
`dart:io` programs (command line tools, build scripts, servers, tests). Two
functions on top of [archive](https://pub.dev/packages/archive): `zip` and
`unzip`.

## Getting started

The package is not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_io_zip:
    git:
      url: https://github.com/tekartik/app_io_utils.dart
      path: packages/app_zip
    version: '>=1.0.0'
```

```dart
import 'package:tekartik_app_io_zip/zip.dart';

Future<void> main() async {
  // Archive the content of lib/ (entries relative to lib/)
  await zip('lib', dst: '.dart_tool/my_tool/lib.zip');
  // Extract it (sub folders created, existing files overwritten)
  await unzip('.dart_tool/my_tool/lib.zip', dst: '.dart_tool/my_tool/lib');
}
```

Without `dst`, `zip('build/web')` writes `build/web.zip` and
`unzip('build/web.zip')` extracts into `build/web`. See
[example/zip_lib_files.dart](example/zip_lib_files.dart).

Platforms: Dart VM and Flutter desktop/mobile (`dart:io`), not the web.

## Errors

`unzip` checks the archive before writing:

* a file that is not a zip, a cut file or damaged data (CRC) throws an
  `ArchiveException` (`package:archive`); the files extracted before a
  damaged entry stay on disk;
* an entry that would be written outside `dst` (`../x`, an absolute name)
  throws a `FileSystemException` and nothing is written.

## Common pitfalls

* `unzip` loads the whole archive in memory: use `package:archive` streams
  (`extractFileToDisk`) for very big archives.
* `unzip` does not clean `dst` first; delete it for an exact copy.
* The unix executable bit is restored on extract when the entry has it, but
  `zip` does not always record it: set it again after extraction if needed.
* A symbolic link entry is extracted as a regular file holding the link
  target.

The [package skill](skills/tekartik-app-io-zip-setup/SKILL.md) has more
examples (build packaging, round trip test).
